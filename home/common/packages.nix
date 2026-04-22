{ pkgs, ... }:
let
  claude-agent-acp-latest = pkgs.claude-agent-acp.overrideAttrs (old: rec {
    version = "0.29.2";

    src = pkgs.fetchFromGitHub {
      owner = "agentclientprotocol";
      repo = "claude-agent-acp";
      tag = "v0.29.2";
      hash = "sha256-YWmsYjIHxg4PLS9Pns6ZuwlBm2SD+1lp5FwIGC2/AeM=";
    };

    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-MAWvqEmWn+Y0Bgy2qBGUzdnjtsWBYVxdM3cSPIgDXMg=";
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
      claude-code-bin
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
