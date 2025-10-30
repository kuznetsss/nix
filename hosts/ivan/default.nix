{ nixpkgs-stable, nixpkgs-unstable, home-manager-stable, sops-nix }:
let
  home-manager = home-manager-stable;
in
nixpkgs-stable.lib.nixosSystem {
  specialArgs = { inherit sops-nix nixpkgs-unstable; };
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
            ../../home/zsh.nix
          ];
        };
    }
  ];
}
