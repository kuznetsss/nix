{ nixpkgs, home-manager, private, disko, agenix, ... }:
let lib = nixpkgs.lib;
in lib.nixosSystem {
  specialArgs = { inherit private agenix; };
  modules = [
    disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix

    ../common/server_base.nix
    {
      networking.hostName = "batou";
      server_base = {
        allowSshFromTailscale = false;
        useDHCP = true;
        networkInterface = "enp4s0";
      };
      services.openssh.openFirewall = lib.mkForce true;
      zramSwap.enable =
        lib.mkForce false; # No need while RAM usage is below 75%

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Disable IPv6 on host
      networking.enableIPv6 = false;
    }

    ./miniflux.nix
    ./power.nix
    ./fan_control.nix
    ./vpn.nix
    ./jellyfin.nix

    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ] ++ private.nixos.batou;
}

