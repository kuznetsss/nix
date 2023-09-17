{ pkgs, ... }: {
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
    nodejs # for github copilot


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
    eza

    python311Packages.ipython
    syncthing
    ranger
    nethack
  ];
}

