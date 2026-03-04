{ pkgs, ... }:
let
  claude-code-acp-latest = pkgs.claude-code-acp.overrideAttrs (old: rec {
    version = "0.20.2";

    src = pkgs.fetchFromGitHub {
      owner = "zed-industries";
      repo = "claude-agent-acp";
      tag = "v0.20.2";
      hash = "sha256-0Oovlv7mkU0BqsNM7RFv5Be+umpmYy29bdmCuQcUheE=";
    };

    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-DjkQUcx/osL+ZBJF7hOQT3qWlaKkB91VelJxReKbOO4=";
    };
  });
in
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
      gh
      gnupg
      # claude-code
      claude-code-acp-latest

      nix
      nixd
      nixfmt
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
