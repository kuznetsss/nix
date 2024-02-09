{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nix-darwin, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.neovim-nightly-overlay.overlay ];
        };
        callPackage = pkgs.callPackage;
      in
      {
        packages.darwinConfigurations.h = callPackage ./darwin/base.nix { inherit nix-darwin; };
        packages.homeConfigurations = {
          h = callPackage ./home/h/h.nix { inherit home-manager; };
          w = callPackage ./home/w/w.nix { inherit home-manager; };
        };
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
