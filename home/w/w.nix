{ home-manager, nixpkgs, util }:
let
  system = util.system.aarch64-darwin;
  pkgs = nixpkgs.legacyPackages.${system};
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "skuznetsov";
      home.homeDirectory = /Users/skuznetsov;
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    }
    ./../tmux.nix
    ./../wezterm.nix
    ./../zsh.nix
    ./../packages.nix
    ./packages.nix
  ];
}
