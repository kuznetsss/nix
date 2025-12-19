{ nixpkgs, home-manager, private, disko, agenix, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit private agenix; };
  modules = [
    disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix

    ../common/server_base.nix
    { networking.hostName = "operator"; }

    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ];
}
