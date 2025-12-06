{ nixpkgs, home-manager, sops-nix, private }:
let lib = nixpkgs.lib;
in lib.nixosSystem {
  specialArgs = { inherit sops-nix private; };
  modules = [
    ./sops.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./wireguard.nix
    ./prosody.nix
    ./logrotate.nix
    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ];
}
