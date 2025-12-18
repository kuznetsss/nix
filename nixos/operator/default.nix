{ nixpkgs, home-manager, private, disko, agenix, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit private agenix; };
  modules = [
    disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix

    ../common/core_server.nix
    {
      networking.hostName = "operator";
      modules.autoupdate.enable = true;
    }

    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ];
}
