{ pkgs, ... }: {
    programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        plugins = with pkgs; [
            {
              name = "zsh-vi-mode";
              src = zsh-vi-mode;
              file = "/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
            }
            {
              name = "zsh-nix-shell";
              src = zsh-nix-shell;
              file = "/nix-shell.plugin";
            }
        ];
        shellAliases = {
            ls = "ls --color=auto";
            ll = "ls -l";
        };
        initExtraFirst = ''
            [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        '';
        initExtra = ''
            bindkey '^ ' autosuggest-accept
            source ~/.zshrc_local
        '';
    };
    programs.starship.enable = true;
    programs.starship.enableZshIntegration = true;
    programs.starship.settings = {
        character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[✖ ➜](bold red)";
            vimcmd_symbol = "[](bold green)";
        };
        directory = {
            truncate_to_repo = false;
        };
    };

}
