{ config, pkgs, private, ... }:
let
  hostName = config.networking.hostName;
  networkConfig = private.network.${hostName};
  sshPort = private.ssh.port;
  lib = pkgs.lib;
in {
  imports = [ ../common/autoupdate.nix ];

  options = {
    server_base.allowSshFromTailscale = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add a firewall rule to open ssh port for tailscale";
    };

    server_base.useDHCP = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description =
        "Whether to use DHCP. If not enabled static config will be taken from private";
    };

    server_base.networkInterface = lib.mkOption {
      type = lib.types.str;
      default = "ens3";
      description = "The network interface to configure";
    };
  };

  config = {
    assertions = [{
      assertion = config.networking.hostName != "nixos";
      message = ''
        networking.hostName must be set to use server_base.nix
        Add { networking.hostName = "some_hostname"; } in your system configuration.
      '';
    }];

    time.timeZone = lib.mkDefault "Europe/London";
    i18n.defaultLocale = "en_US.UTF-8";
    services.journald.extraConfig = "SystemMaxUse=2G";

    networking = {
      useDHCP = lib.mkForce false;
      firewall = {
        enable = true;
        logRefusedConnections = false;
        allowPing = true;
        extraCommands =
          "iptables -A INPUT -i tailscale0 -p tcp -m tcp --dport ${
            toString sshPort
          } -j ACCEPT";
      };
    };

    systemd.network = {
      enable = true;
      networks."10-${config.server_base.networkInterface}" = {
        matchConfig.Name = config.server_base.networkInterface;

        address = lib.mkIf (!config.server_base.useDHCP)
          [ (networkConfig.ip + "/" + toString networkConfig.prefixLength) ];
        routes = lib.mkIf (!config.server_base.useDHCP) [{
          Gateway = networkConfig.gateway;
        }];

        DHCP = lib.mkIf config.server_base.useDHCP "yes";
        dhcpV4Config = lib.mkIf config.server_base.useDHCP { UseDNS = true; };
      };
    };

    users.users = {
      sergey = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        initialPassword = "some_passwd";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [ private.ssh.pubKeys.mac ];
      };
    };

    nix = {
      optimise.automatic = true;
      settings.experimental-features = [ "nix-command" "flakes" ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 3d";
      };
    };
    environment.systemPackages = with pkgs; [ neovim htop git traceroute dig ];

    programs.zsh.enable = true;

    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = lib.mkDefault "lz4";
      priority = 10;
    };

    swapDevices = [{
      device = "/var/lib/swapfile";
      size = lib.mkDefault (3 * 512); # 1.5GB
      priority = 5;
    }];

    systemd.oomd.enable = false;
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 1;
      freeSwapThreshold = 1;
      freeMemKillThreshold = 3;
      freeSwapKillThreshold = 3;
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      ports = [ sshPort ];
      openFirewall = lib.mkDefault false;
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    system.stateVersion = "25.11";
  };
}
