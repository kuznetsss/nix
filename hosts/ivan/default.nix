{ nixpkgs-stable, home-manager-stable, sops-nix }:
let
  home-manager = home-manager-stable;
in
nixpkgs-stable.lib.nixosSystem {
  specialArgs = { inherit sops-nix; };
  modules = [
    ./sops.nix
    ./configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.sergey = { pkgs, ... }:
        {
          home.stateVersion = "23.11";
          imports = [
            ../../home/zsh.nix
          ];
        };
    }
  ];
}
