{ home-manager, nixpkgs, util, }:
let
  system = util.system.aarch64-darwin;
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "sergey";
      home.homeDirectory = /Users/sergey;
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    }
    ./../common/tmux.nix
    ./../common/jujutsu.nix
    ./../common/wezterm.nix
    ./../common/zsh.nix
    ./../common/packages.nix
    ./packages.nix
  ];
}
