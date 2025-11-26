{ pkgs, private, ... }:
let
  network_config = private.network.operator;
  ssh_port = 21587;
in {
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";
  services.journald.extraConfig = "SystemMaxUse=2G";

  networking = {
    hostName = "operator";
    useDHCP = false;
    firewall = {
      enable = true;
      logRefusedConnections = false;
      allowPing = true;
      extraCommands = "iptables -A INPUT -i tailscale0 -p tcp -m tcp --dport ${
          toString ssh_port
        } -j ACCEPT";
    };
  };

  systemd.network = {
    enable = true;
    networks."10-ens3" = {
      matchConfig.Name = "ens3";
      address =
        [ (network_config.ip + "/" + toString network_config.prefixLength) ];
      routes = [{ Gateway = network_config.gateway; }];
    };
  };

  users.users = {
    sergey = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      initialPassword = "some_passwd";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ private.ssh.home_mac_pub_key ];
    };
    deployer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ private.ssh.home_mac_pub_key ];
    };
  };

  security.sudo.extraConfig = ''
    deployer ALL = (root) NOPASSWD:/run/current-system/sw/bin/nixos-rebuild
  '';

  nix = {
    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };
  environment.systemPackages = with pkgs; [ neovim htop git ];

  programs.zsh.enable = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 3 * 512; # 1.5GB
  }];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    ports = [ ssh_port ];
    openFirewall = false;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  system.stateVersion = "25.05";
}
