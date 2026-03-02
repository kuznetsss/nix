{ pkgs, ... }:
let
  claude-code-acp-latest = pkgs.buildNpmPackage {
    pname = "claude-code-acp";
    version = "0.19.2";

    src = pkgs.fetchFromGitHub {
      owner = "zed-industries";
      repo = "claude-agent-acp";
      tag = "v0.19.2";
      hash = "sha256-MGy6hdOwIASh4qirCaQBF2czVWEkYiRzqXMm9qun5Tk=";
    };

    npmDepsHash = "sha256-UZJZfGmmbHKSlRXmIC5hqZNTJ5k3EQO79mGjWaKtgDE=";

    meta = {
      description = "ACP-compatible coding agent powered by the Claude Code SDK";
      homepage = "https://github.com/zed-industries/claude-agent-acp";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "claude-code-acp";
    };
  };
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
      claude-code
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
