{ nixpkgs, home-manager, private, disko, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit private; };
  modules = [
    disko.nixosModules.disko
    ./configuration.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ];
}
