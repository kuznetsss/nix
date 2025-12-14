{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      neovim

      # development
      nodePackages.cspell
      zk
      rumdl
      yamllint
      yaml-language-server
      lua-language-server
      imagemagick
      selene
      stylua
      ripgrep
      lazygit
      lazyjj
      jjui
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
      uutils-coreutils-noprefix
      websocat
      yazi

      nethack
    ] ++ (if pkgs.stdenv.isDarwin then [ iproute2mac darwin.trash ] else [ ]);
}
