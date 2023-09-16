{ pkgs, ... }: {
  home.username = "sergey";
  home.homeDirectory = /Users/sergey;
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim

    # development
    zk
    yamllint
    yaml-language-server
    lua-language-server
    black
    stylua
    luajitPackages.luacheck
    ripgrep
    lazygit


    # rust
    rust-analyzer
    rustfmt
    rustc
    cargo

    go

    # system
    darwin.iproute2mac
    darwin.trash
    bitwarden-cli
    htop
    nmap
    wget
    openssh
    tmux

    python311Packages.ipython
    syncthing
    ranger
    nethack
  ];
}

