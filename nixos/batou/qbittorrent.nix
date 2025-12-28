{ config, pkgs, private, ... }:
let
  webUIPort = 8080;
  torrentingPort = private.network.batou.torrentingPort;
  networkInterface = config.server_base.networkInterface;
in {
  services.qbittorrent = {
    enable = true;
    webuiPort = webUIPort;
    inherit torrentingPort;
  };

  systemd.services."qbittorrent-firewall" = {
    after = [ "wg0-setup.service" ];
    bindsTo = [ "wg0-setup.service" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "add-qbt-fw" ''
        ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p tcp --dport ${
          toString torrentingPort
        } -j ACCEPT
        ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp --dport ${
          toString torrentingPort
        } -j ACCEPT
      '';
      ExecStop = pkgs.writeShellScript "del-qbt-fw" ''
        ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --dport ${
          toString torrentingPort
        } -j ACCEPT
        ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -D INPUT -p udp --dport ${
          toString torrentingPort
        } -j ACCEPT
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services.qbittorrent = {
    requires = [ "qbittorrent-firewall.service" "wg0-setup.service" ];
    after = [ "qbittorrent-firewall.service" "wg0-setup.service" ];
    bindsTo = [ "wg0-setup.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/${config.vpnNamespace}";
      BindReadOnlyPaths =
        "/etc/netns/${config.vpnNamespace}/resolv.conf:/etc/resolv.conf";
    };
  };

  # Create a reverse proxy to access qBittorrent from the host using systemd-socket-proxyd
  systemd.sockets.qbittorrent-proxy = {
    description = "qBittorrent proxy socket";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "${toString webUIPort}" ];
  };

  systemd.services.qbittorrent-proxy = {
    description = "qBittorrent proxy to VPN namespace";
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${
          toString webUIPort
        }";
      PrivateNetwork = true;
      NetworkNamespacePath = "/var/run/netns/${config.vpnNamespace}";
    };
  };

  networking.firewall.interfaces.${networkInterface}.allowedTCPPorts =
    [ webUIPort ];
}

