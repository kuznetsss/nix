{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    mouse = false;
    historyLimit = 10000;
    keyMode = "vi";
    plugins = with pkgs; [
      tmuxPlugins.continuum
      tmuxPlugins.resurrect
    ];
    prefix = "C-b";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    extraConfig = ''
      # fix unwanted PATH update
      set -g default-command ${pkgs.zsh}/bin/zsh

      # allow true colors
      set -as terminal-overrides ",*:Tc"

      # don't rename windows automatically
      set-option -g allow-rename off

      # enable focus events for vim
      set -s focus-events on

      # save history
      set -g history-file ~/.cache/.tmux_history

      bind-key C-b select-pane -t :.+

      # bindings for vi mode
      bind P paste-buffer
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      bind v copy-mode

      set -g update-environment -r

      # Open new panes and windows in current directory
      bind-key c new-window -c "#{pane_current_path}"
      bind-key % split-window -h -c "#{pane_current_path}"
      bind-key '"' split-window -v -c "#{pane_current_path}"

      # fix ssh agent when tmux is detached
      setenv -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock

      # loud or quiet?
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # colors
      set -g status-style ' fg=#AAAAAA bg=#272727'
      setw -g window-status-current-style 'fg=#BBBBBB bg=#353535 bold'

      # restore tmux session
      set -g @resurrect-dir "$HOME/.config/tmux/resurrect"
      set -g @continuum-restore 'on'
    '';
  };
}
