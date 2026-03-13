{ pkgs, ... }:
let
  claude-code-acp-latest = pkgs.claude-code-acp.overrideAttrs (old: rec {
    version = "0.21.0";

    src = pkgs.fetchFromGitHub {
      owner = "zed-industries";
      repo = "claude-agent-acp";
      tag = "v0.21.0";
      hash = "sha256-6c6bHuso3diW5ZfHiM2xcxGDTNG0LIL0TZd0MFVpW/E=";
    };

    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-UtiIcjgNCYMFrRpO5AlUbOyutJ3ipwIbcpMi2BqawEk=";
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
