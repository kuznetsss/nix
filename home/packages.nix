{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim

    # development
    nodePackages.cspell
    zk
    yamllint
    yaml-language-server
    lua-language-server
    black
    stylua
    luajitPackages.luacheck
    ripgrep
    lazygit
    nodejs # for github copilot

    # nix
    nixd
    statix
    nvd

    # rust
    rust-analyzer
    rustfmt
    rustc
    cargo

    go

    # system
    darwin.iproute2mac
    darwin.trash
    htop
    nmap
    wget
    openssh
    tmux
    eza

    python311Packages.ipython
    ranger
    nethack
  ];
}

