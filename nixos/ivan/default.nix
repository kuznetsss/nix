{ nixpkgs, home-manager, sops-nix }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit sops-nix; };
  modules = [
    ./sops.nix
    ./configuration.nix
    ./wireguard.nix
    ./prosody.nix
    ./logrotate.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
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
