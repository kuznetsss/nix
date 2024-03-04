{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-stable.url = "github:nix-community/home-manager/release-23.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    deploy-rs.url = "github:serokell/deploy-rs";
    sops-nix.url = "github:Mic92/sops-nix";
    git-agecrypt.url = "github:kuznetsss/git-agecrypt";
  };

  outputs = { self, nix-darwin, nixpkgs, nixpkgs-stable, home-manager, home-manager-stable, deploy-rs, sops-nix, ... }@inputs:
    let
      util = import ./util { inherit nixpkgs; };
      overlays = [
        # inputs.neovim-nightly-overlay.overlay
        inputs.git-agecrypt.overlay
      ];
    in
    {
      darwinConfigurations.h = import ./darwin/base.nix { inherit nix-darwin nixpkgs util; };


      homeConfigurations = {
        h = import ./home/h/h.nix { inherit nixpkgs home-manager util overlays; };
        w = import ./home/w/w.nix { inherit nixpkgs home-manager util; };
      };

      nixosConfigurations.ivan = import ./hosts/ivan { inherit nixpkgs-stable home-manager-stable sops-nix util; };

      deploy.nodes.ivan = import ./hosts/ivan/deploy.nix { inherit self deploy-rs; };

      # TODO: uncomment when remote testing will be available in deploy-rs
      # see https://github.com/serokell/deploy-rs/issues/167
      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;

      formatter = util.forEachSystem (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
