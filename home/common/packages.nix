{ pkgs, ... }:
let
  # claude-agent-acp-latest = pkgs.claude-agent-acp.overrideAttrs (old: rec {
  #   version = "0.31.4";
  #
  #   src = pkgs.fetchFromGitHub {
  #     owner = "agentclientprotocol";
  #     repo = "claude-agent-acp";
  #     tag = "v0.31.4";
  #     hash = "sha256-cXTtDekC0+n1NCgTzIyGSqHEgpgdHP6EVI23L4nCbWE=";
  #   };
  #
  #   npmDeps = pkgs.fetchNpmDeps {
  #     inherit src;
  #     hash = "sha256-PmcE99h303iOH5OJ4wCwxgR+0zVJM8O5A3ZyBgPxJeM=";
  #   };
  # });
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
      claude-code
      claude-agent-acp

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
