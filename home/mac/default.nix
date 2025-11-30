{ home-manager, nixpkgs, util, }:
let
  system = util.system.aarch64-darwin;
  pkgs = import nixpkgs { inherit system; };
in home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "sergey";
      home.homeDirectory = /Users/sergey;
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
    }
    ./../common/tmux.nix
    ./../common/jjui.nix
    ./../common/wezterm.nix
    ./../common/zsh.nix
    ./../common/packages.nix
    ./packages.nix
  ];
}
