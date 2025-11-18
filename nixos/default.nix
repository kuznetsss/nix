{ nixpkgs, home-manager, sops-nix, private, disko }: {
  ivan = import ./ivan {
    inherit nixpkgs home-manager private sops-nix;
  };
  operator = import ./operator {
    inherit nixpkgs home-manager private disko;
  };
}
