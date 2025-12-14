{ pkgs, hostName, private, ... }:
let
  networkConfig = private.network.${hostName};
  sshPort = private.ssh.port;
  lib = pkgs.lib;
in
  {
  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";
  services.journald.extraConfig = "SystemMaxUse=2G";

  networking = {
    inherit hostName;
    useDHCP = lib.mkForce false;
    firewall = {
      enable = true;
      logRefusedConnections = false;
      allowPing = true;
      extraCommands = "iptables -A INPUT -i tailscale0 -p tcp -m tcp --dport ${
          toString sshPort
        } -j ACCEPT";
    };
  };

  systemd.network = {
    enable = true;
    networks."10-ens3" = {
      matchConfig.Name = "ens3";
      address =
        [ (networkConfig.ip + "/" + toString networkConfig.prefixLength) ];
      routes = [{ Gateway = networkConfig.gateway; }];
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
    deployer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ private.ssh.pubKeys.mac ];
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
    ports = [ sshPort ];
    openFirewall = false;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  system.stateVersion = "25.11";
}
