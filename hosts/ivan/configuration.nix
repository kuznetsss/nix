{ pkgs, ... }:
let
  network_config = import ./network.nix;
  ssh_port = 21587;
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking = {
    hostName = "ivan";
    wireless.enable = false;
    networkmanager.enable = false;
    dhcpcd.enable = true;
    useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = network_config.ip;
      prefixLength = 24;
    }];
    defaultGateway = {
      address = network_config.gateway;
      interface = "ens3";
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      logRefusedConnections = false;
      allowPing = true;
      extraCommands = "iptables -A INPUT -i tailscale0 -p tcp -m tcp --dport ${toString ssh_port} -j ACCEPT";
    };
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = false;

  users.users.sergey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTWcVEWS+jlt+NmlxG9gVIUYifVFoO9ldesyPFUhYVyTvUPPFOAKr2ZBYyOakgBWZ90AOvpOwpqYvE4SdH8c1S8SZUcfNAZiqHC77AehXSm4PJgLznrm6XnIvW7YpX1ysf45tKzgzOd3u9AE2oa6rUOwjkfX5DAvUL/Vn2btoupuwEB18fFgWYwEU6+IcZHeYEh5rbNm7QxUih87MfZAEtr49h8XX4vj1qJuk4IzZ0/o7QlbsJcCLtcU+j6/dNEGqTRVOLUPp96iuoZStDonVtwYaYlJWJodEeSkYZYkrU+I8Z0cPZ3KMPtdaKzsC58ecSG+h2p1rtLaMccALIp+QvE2x4qYFEH1CrSNuMb8U0PyjzFvmasiT0V7Bvc/hZR6fYIz/LcKQ8D2uDXnYOhzYDFJ67aCP8IOI8R6MREa8Cv+IgMMz2+GdNB0ry7cbmIwnLdjQoIiwFLrzRJk3wNkUhYLs59Krpr87so0kCNsASW80f+38DP1bYwizCDrGkH8QycGnh9ecYj5LvXroHswtBV+cYyHph9OXGTIfrRs9VaXa38I+hf/dJ0qCmo7DYrNhCd1kiP8g+HDDG2qqjH28nJNuJUkjxV17xtHi+S2wyssE3RMXH2yG6qGGYqXe4Llx+E2tx3LNFx4vcrCvfo/darMd83cpVLWlEvFycCnBkLQ== sergey@Sergeys-Laptop" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/BKcELLlCW5YTlacXEI1kGQogIqh+JfTEFBFOyremD sergey@georgiaslaptop" ];
    packages = with pkgs; [
      nvd
    ];
    shell = pkgs.zsh;
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
  };
  environment.systemPackages = with pkgs; [
    neovim
    htop
    deploy-rs
  ];

  programs.zsh.enable = true;

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

