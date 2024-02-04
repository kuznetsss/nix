{ ... }: {
  programs.wezterm = {
    enable = true; # use from brew instead
    enableZshIntegration = false;
    extraConfig = ''
      local wezterm = require 'wezterm'
      return {
        allow_square_glyphs_to_overflow_width = "Always",
        color_scheme = 'Tomorrow (dark) (terminal.sexy)',
        hide_tab_bar_if_only_one_tab = true,
        font = wezterm.font('JetBrains Mono', {weight='Regular'}),
        font_rules = {
          {
            italic = false,
            intensity = "Bold",
            font = wezterm.font('JetBrains Mono', {weight='Bold'}),
          },
          {
            italic = true,
            intensity = "Normal",
            font = wezterm.font('JetBrains Mono', {weight='Regular', italic=true}),
          },
          {
            italic = true,
            intensity = "Bold",
            font = wezterm.font('JetBrains Mono', {weight='Bold', italic=true}),
          },
          {
            italic = false,
            intensity = "Half",
            font = wezterm.font('JetBrains Mono', {weight='Light'}),
          },
          {
            italic = true,
            intensity = "Half",
            font = wezterm.font('JetBrains Mono', {weight='Light', italic=true}),
          },
        },
        font_size = 14.0,
        foreground_text_hsb = {
          hue = 1.0,
          saturation = 1.0,
          brightness = 1.0,
        },
        force_reverse_video_cursor = true,
        window_padding = {
          left = 2,
          right = 0,
          top = 0,
          bottom = 0,
        },
      }

    '';
  };

  }
