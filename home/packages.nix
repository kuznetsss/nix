{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    neovide

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
    nixfmt-classic
    statix
    nvd
    age
    sops

    go
    gopls
    golangci-lint

    # system
    htop
    nmap
    wget
    openssh
    tmux
    gnused
    unixtools.watch
    coreutils-full

    yazi
    nethack
  ] ++ (if pkgs.stdenv.isDarwin then [
    iproute2mac
    darwin.trash
  ] else []);
}

