{
  config,
  pkgs,
  lib,
  ...
}:
let
  stdenv = pkgs.stdenv;
in
{
  programs.zsh = {
    autosuggestion.enable = true;
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    plugins = with pkgs; [
      {
        name = "zsh-nix-shell";
        src = zsh-nix-shell;
        file = "nix-shell.plugin";
      }
      {
        name = "history-search-multi-word";
        file = "history-search-multi-word.plugin.zsh";
        src = fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "history-search-multi-word";
          rev = "c4dcddc1cd17e7e0909471703f3526170db0f475";
          sha256 = "sha256-KgKm9qzFnwXDXwmTruPgC0tjmiTY5AiGdrWW4zDWUF4=";
        };
      }
    ];
    sessionVariables = {
      EDITOR = "nvim";
      KEYTIMEOUT = 1;
    };
    shellAliases = {
      rm = lib.mkIf stdenv.isDarwin "trash";
      pre-commit = lib.mkIf (lib.elem pkgs.prek config.home.packages) "prek";
    };
    history = {
      ignoreAllDups = true;
    };
    initContent =
      let
        before = lib.mkBefore ''
          [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        '';
        after = lib.mkAfter ''
          export KEYTIMEOUT=1
          bindkey -v
          bindkey '^?' backward-delete-char
          bindkey '^P' up-history
          bindkey '^N' down-history
          bindkey '^ ' autosuggest-accept
          autoload edit-command-line
          zle -N edit-command-line
          bindkey -v '^v' edit-command-line
          bindkey -M vicmd '^v' edit-command-line
          [ -f ~/.zshrc_local ] && source ~/.zshrc_local
        '';
      in
      lib.mkMerge [
        before
        after
      ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖ ➜](bold red)";
        vimcmd_symbol = "[](bold green)";
      };
      directory = {
        truncate_to_repo = false;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

}
