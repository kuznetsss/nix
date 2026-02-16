{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      neovim

      # development
      tree-sitter
      nodePackages.cspell
      zk
      yamllint
      yaml-language-server
      lua-language-server
      imagemagick
      selene
      stylua
      ripgrep
      lazygit
      jjui
      nodejs # for github copilot
      gh
      gnupg
      claude-code
      claude-code-acp

      chatgpt-cli

      nix
      nixd
      nixfmt
      statix
      nvd

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
      spotify-player
      spotifyd
    ]
    ++ (
      if pkgs.stdenv.isDarwin then
        [
          iproute2mac
          darwin.trash
        ]
      else
        [ ]
    );
}
