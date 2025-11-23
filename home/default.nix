{ nixpkgs, home-manager, util, }: {
  mac = import ./mac { inherit nixpkgs home-manager util; };
  work_mac = import ./work_mac { inherit nixpkgs home-manager util; };
  work_devserver =
    import ./work_devserver { inherit nixpkgs home-manager util; };
}
