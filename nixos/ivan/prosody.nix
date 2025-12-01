{ config, pkgs, private, ... }:
let
  network_config = private.network.ivan;
  domain = network_config.domain;
in {
  users.users.prosody.extraGroups = [ "nginx" "turnserver" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "kuzzz99@gmail.com";
    certs = {
      "${domain}" = {
        extraDomainNames = [
          "conference.${domain}"
          "proxy.${domain}"
          "pubsub.${domain}"
          "upload.${domain}"
        ];
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = { return = "403"; };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80 # nginx http
      443 # nginx https
      5000 # prosody file transfer proxy
      5222 # prosody client connection
      5223 # prosody client direct tls
      5224 # prosody s2s direct tls
      5269 # prosody s2s
      5281 # prosody https
      config.services.coturn.listening-port
      config.services.coturn.tls-listening-port
    ];
    allowedUDPPorts = [
      config.services.coturn.listening-port
      config.services.coturn.tls-listening-port
    ];
    allowedUDPPortRanges = [{
      from = config.services.coturn.min-port;
      to = config.services.coturn.max-port;
    }];
  };

  services.prosody = {
    enable = true;
    checkConfig = false;
    package = pkgs.prosody.override {
      withCommunityModules = [
        "log_auth"
        "csi_battery_saver"
        # "sasl_ssdp"
        # "sasl2"
        # "sasl2_bind2"
        # "sasl2_sm"
        # "sasl2_fast"
      ];
    };

    admins = [ "sergey@${domain}" ];
    ssl = {
      cert = "/var/lib/acme/${domain}/fullchain.pem";
      key = "/var/lib/acme/${domain}/key.pem";
      extraOptions = { protocol = "tlsv1_3"; };
    };
    virtualHosts."${domain}" = {
      enabled = true;
      domain = "${domain}";
      ssl.cert = "/var/lib/acme/${domain}/fullchain.pem";
      ssl.key = "/var/lib/acme/${domain}/key.pem";
    };
    log = ''
      {
        { levels = { min = "info" }, to = "file", filename = "/var/lib/prosody/log" },
      }
    '';
    muc = [{ domain = "conference.${domain}"; }];
    httpFileShare = { domain = "upload.${domain}"; };
    modules = {
      csi = false;
      groups = true;
      http_files = false;
      vcard = true;
      vcard_legacy = false;
      watchregistrations = true;
    };
    extraModules = [ "turn_external" ];
    s2sSecureAuth = true;
    extraConfig = ''
      certificates = '/var/lib/acme/${domain}'
      groups_file = '/var/lib/prosody/groups.txt'
      archive_expires_after = "3d"
      http_file_share_expires_after = 3*24*60*60;
      http_file_share_size_limit = 100 * 1024 * 1024
      network_settings = { tcp_fastopen = 256; }
      storage = "sql"
      sql = { driver = "SQLite3", database = "prosody.sqlite" }
      smacks_hibernation_time = 24*60*60 -- 24h
      c2s_direct_tls_ports = { 5223 }
      s2s_direct_tls_ports = { 5224 }
      turn_external_host = "${domain}"
      turn_external_port = ${toString config.services.coturn.listening-port}


      turn_external_secret = (function()
        local secret_path = "${config.sops.secrets."ivan/coturn_auth_key".path}"
        local file = assert(io.open(secret_path, "r"))
        local data = file:read("*a")
        file:close()
        return data
      end)()

    '';
  };

  services.coturn = {
    enable = true;
    cert = "/var/lib/acme/${domain}/fullchain.pem";
    pkey = "/var/lib/acme/${domain}/key.pem";
    realm = "${domain}";
    no-tcp-relay = true;
    # listening-port = 50000;
    # tls-listening-port = 50002;
    # min-port = 50004;
    # max-port = 51000;
    static-auth-secret-file =
      "${config.sops.secrets."ivan/coturn_auth_key".path}";
    # static-auth-secret = "${coturn_auth_key}";
    use-auth-secret = true;
    listening-ips = [ "${network_config.ip}" ];
    relay-ips = [ "${network_config.ip}" ];
    extraConfig = ''
      no-multicast-peers
      # For security reasons, disable older STUN backward compatibility.
      no-stun-backward-compatibility
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255

      # recommended additional local peers to block, to mitigate external access to internal services.
      # https://www.rtcsec.com/article/slack-webrtc-turn-compromise-and-bug-bounty/#how-to-fix-an-open-turn-relay-to-address-this-vulnerability
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255

      # special case the turn server itself so that client->TURN->TURN->client flows work
      # this should be one of the turn server's listening IPs
      allowed-peer-ip=10.0.0.1

      # consider whether you want to limit the quota of relayed streams per user (or total) to avoid risk of DoS.
      total-quota=1200
      # Verbose
      # fingerprint
    '';
  };

  environment.etc = {
    "fail2ban/filter.d/prosody-auth.local" = {
      text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = Failed authentication attempt \(not-authorized\) for user .* from IP: <HOST>
        ignoreregex =
      '');
      mode = "0444";
    };
    "fail2ban/filter.d/nginx-4xx.local" = {
      text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST>.*" (404|444|403|400) .*$
        ignoreregex =
      '');
      mode = "0444";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [ "100.0.0.0/8" ];
    bantime = "24h";
    jails = {
      prosody.settings = {
        enabled = true;
        port = 5222;
        backend = "auto";
        filter = "prosody-auth";
        logpath = "/var/lib/prosody/log";
      };
      nginx-bad-request.settings = {
        enabled = true;
        backend = "auto";
        port = "http,https";
        logpath = "/var/log/nginx/access.log";
      };
      nginx-4xx.settings = {
        enabled = true;
        port = "http,https";
        backend = "auto";
        logpath = "/var/log/nginx/access.log";
      };
    };
  };

}
