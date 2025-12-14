{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    agenix.url = "github:ryantm/agenix";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private-part = {
      url = "git+ssh://git@github.com/kuznetsss/nix_private.git";
      flake = false;
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, home-manager-stable, agenix
    , disko, private-part, ... }:
    let
      util = import ./util { inherit nixpkgs; };
      private = import private-part;
    in {
      homeConfigurations = import ./home { inherit nixpkgs home-manager util; };

      nixosConfigurations = import ./nixos {
        nixpkgs = nixpkgs-stable;
        home-manager = home-manager-stable;
        inherit agenix private disko;
      };

      deploy = import ./nixos/deploy.nix;

      formatter =
        util.forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
