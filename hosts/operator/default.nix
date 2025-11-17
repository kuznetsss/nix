{ nixpkgs, home-manager, private, disko, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit private; };
  modules = [
    disko.nixosModules.disko
    ./configuration.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.sergey = { ... }:
        {
          home.stateVersion = "25.05";
          imports = [
            ../../home/common/zsh.nix
          ];
        };
    }
  ];
}
