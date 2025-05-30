{ home-manager, nixpkgs, util, overlays }:
let
  system = util.system.aarch64-darwin;
  pkgs = import nixpkgs { inherit system overlays; };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "sergey";
      home.homeDirectory = /Users/sergey;
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
    }
    ./../tmux.nix
    ./../wezterm.nix
    ./../zsh.nix
    ./../packages.nix
    ./packages.nix
  ];
}

