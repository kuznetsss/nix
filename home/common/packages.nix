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
<<<<<<< conflict 1 of 1
+++++++ wnuxptls d39645e0 "chore: update flake.lock" (rebase destination)
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
%%%%%%% diff from: mvznryrs 0c230d6d "chore: update flake.lock" (parents of rebased revision)
\\\\\\\        to: yysszrlt 1ce27309 "Use prek instead of pre-commit. Remove rumdl" (rebased revision)
-    ] ++ (if pkgs.stdenv.isDarwin then [ iproute2mac darwin.trash ] else [ ]);
+    ]
+    ++ (
+      if pkgs.stdenv.isDarwin then
+        [
+          iproute2mac
+          darwin.trash
+        ]
+      else
+        [ ]
+    );
>>>>>>> conflict 1 of 1 ends
}
