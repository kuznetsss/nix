{ pkgs, ... }: {
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    rust-analyzer
    yamllint
    go
    lua-language-server
    rustfmt
    darwin.trash
    neovim
    zk
    bitwarden-cli
    lazygit
    luajitPackages.luacheck
    nethack
    black
    nmap
    htop
    ranger
    stylua
    syncthing
    wget
    darwin.iproute2mac
    openssh
    ripgrep
    python311Packages.ipython
    rustc
    cargo
    tmux
    yaml-language-server
  ];
}

