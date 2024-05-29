{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim

    # development
    nodePackages.cspell
    zk
    yamllint
    yaml-language-server
    lua-language-server
    selene
    stylua
    ripgrep
    lazygit
    nodejs # for github copilot
    gh
    gnupg

    chatgpt-cli

    nix
    nixd
    statix
    nvd
    age
    sops

    go

    # system
    darwin.iproute2mac
    darwin.trash
    htop
    nmap
    wget
    openssh
    tmux
    gnused
    unixtools.watch
    coreutils-full

    python311Packages.ipython
    ranger
    nethack
  ];
}

