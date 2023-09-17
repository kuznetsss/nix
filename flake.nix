{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      callPackage = pkgs.callPackage;
    in
    {
      darwinConfigurations.hl = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin/base.nix
        ];
      };

      homeConfigurations.h = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home.username = "sergey";
            home.homeDirectory = /Users/sergey;
            home.stateVersion = "23.05";
            programs.home-manager.enable = true;
          }
          ./home/packages.nix
          ./home/zsh.nix
        ];
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
