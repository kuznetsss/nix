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
      darwinConfigurations."Sergeys-Laptop" = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin.nix
          # home-manager.darwinModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   users.users.sergey = {
          #     name = "sergey";
          #     home = "/Users/sergey";
          #   };
          #   home-manager.users.sergey = import ./home.nix;
          # }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      # darwinPackages = self.darwinConfigurations."Sergeys-Laptop".pkgs;

      homeConfigurations."sergey" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # home-manager.useGlobalPkgs = true;
        # home-manager.useUserPackages = true;
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
            ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
