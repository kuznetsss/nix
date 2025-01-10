{ ... }: {
  programs.wezterm = {
    enable = true; # use from brew instead
    enableZshIntegration = false;
    extraConfig = ''
      local wezterm = require 'wezterm'
      return {
        allow_square_glyphs_to_overflow_width = "Always",
        color_scheme = 'Tomorrow (dark) (terminal.sexy)',
        colors = {
          tab_bar = {
            background = '#272727',
            active_tab = {
              bg_color = '#353535',
              fg_color = '#bbbbbb',

              -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
              -- label shown for this tab.
              -- The default is "Normal"
              intensity = 'Bold',
              underline = 'None',
              italic = false,
              strikethrough = false,
            },

            -- Inactive tabs are the tabs that do not have focus
            inactive_tab = {
              bg_color = '#272727',
              fg_color = '#aaaaaa',
            },
          },
        },
        default_gui_startup_args = { 'connect', 'unix' },
        hide_tab_bar_if_only_one_tab = false,
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
        native_macos_fullscreen_mode = true,
        window_padding = {
          left = 2,
          right = 0,
          top = 2,
          bottom = 0,
        },
        use_fancy_tab_bar = false,
        unix_domains = {
          {
            name = 'unix',
            local_echo_threshold_ms = 1000,
          },
        }
      }
    '';
  };

}
