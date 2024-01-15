{ home-manager, pkgs, ... }:
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "sergey";
      home.homeDirectory = /Users/sergey;
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
    }
    ./../zsh.nix
    ./../tmux.nix
    ./../packages.nix
    ./packages.nix
  ];
}

