{ nixpkgs, home-manager, agenix, private, ... }:
let lib = nixpkgs.lib;
in lib.nixosSystem {
  specialArgs = { inherit agenix private; };
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./wireguard.nix
    ./prosody.nix
    ./logrotate.nix
    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
    ./secrets.nix
  ];
}
