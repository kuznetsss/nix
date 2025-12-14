{ nixpkgs, home-manager, private, disko, agenix, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit private; };
  modules = [
    disko.nixosModules.disko
    ./configuration.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
    agenix.nixosModules.default
    {
      age.secrets.test.file = private.secretPath {
        host = "operator";
        name = "test";
      };
    }
  ];
}
