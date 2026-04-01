{ pkgs, ... }:
let
  claude-agent-acp-latest = pkgs.claude-agent-acp.overrideAttrs (old: rec {
    version = "0.24.2";

    src = pkgs.fetchFromGitHub {
      owner = "agentclientprotocol";
      repo = "claude-agent-acp";
      tag = "v0.24.2";
      hash = "sha256-SRVbLcGrH5pJt6yfM0ObSso68M+yGateIVYf/kFVDhE=";
    };

    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-V5lBQNhpL+/Mok9bEVSOrrHSv9B9pXKJswcXW+QDnAs=";
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
      cspell
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
      #claude-code
      claude-agent-acp-latest

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
