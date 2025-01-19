{ ... }: {
  programs.wezterm = {
    enable = true; # use from brew instead
    enableZshIntegration = false;
    extraConfig = ''
      local colors = {
        tab_bar = {
          background = '#272727',
          active_tab = {
            bg_color = '#353535',
            fg_color = '#bbbbbb',
            intensity = 'Bold',
          },

          -- Inactive tabs are the tabs that do not have focus
          inactive_tab = {
            bg_color = '#272727',
            fg_color = '#aaaaaa',
          },
        },
      }

      local keys = {
        {
          mods = 'CMD',
          key = 's',
          action = wezterm.action.ActivateCopyMode,
        },
        {
          mods = 'CMD',
          key = 'n',
          action = wezterm.action.ActivateTabRelative(1),
        },
        {
          mods = 'CMD',
          key = 'p',
          action = wezterm.action.ActivateTabRelative(-1),
        },
        {
          mods = 'CMD',
          key = 'x',
          action = wezterm.action.CloseCurrentPane { confirm = true },
        },
        {
          mods = 'CMD',
          key = 'w',
          action = wezterm.action.CloseCurrentTab { confirm = true },
        },
        {
          mods = 'CMD',
          key = 'a',
          action = wezterm.action.QuickSelect,
        },
        {
          mods = 'CMD',
          key = 'u',
          action = wezterm.action.ScrollByPage(-0.8),
        },
        {
          mods = 'CMD',
          key = 'd',
          action = wezterm.action.ScrollByPage(0.8),
        },
        {
          mods = 'CMD',
          key = '/',
          action = wezterm.action.Search { CaseInSensitiveString = "" },
        },
        {
          mods = 'CMD',
          key = 'y',
          action = wezterm.action.ShowTabNavigator,
        },
        {
          mods = 'CMD',
          key = 't',
          action = wezterm.action.SpawnTab 'CurrentPaneDomain',
        },
        {
          mods = 'CMD',
          key = 'i',
          action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
          mods = 'CMD',
          key = 'o',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        {
          mods = 'CMD',
          key = 'g',
          action = wezterm.action.ScrollToBottom,
        },
        {
          mods = 'CMD',
          key = 'G',
          action = wezterm.action.ScrollToTop,
        },
        {
          mods = 'LEADER',
          key = 'n',
          action = wezterm.action.MoveTabRelative(1),
        },
        {
          mods = 'LEADER',
          key = 'p',
          action = wezterm.action.MoveTabRelative(-1),
        },
        {
          mods = 'LEADER',
          key = 'Space',
          action = wezterm.action.RotatePanes 'CounterClockwise',
        },
        {
          mods = 'CMD',
          key = 'z',
          action = wezterm.action.TogglePaneZoomState,
        },
        {
          mods = 'LEADER',
          key = 'r',
          action = wezterm.action.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
              if line then
                window:active_tab():set_title(line)
              end
            end),
          },
        }
      }

      for key, dir in pairs { h = 'Left', j = 'Down', k = 'Up', l = 'Right' } do
         table.insert(keys, {
           mods = 'CMD',
           key = key,
           action = wezterm.action.ActivatePaneDirection(dir),
         })
         table.insert(keys, {
           mods = 'LEADER',
           key = key,
           action = wezterm.action.AdjustPaneSize { dir, 5 },
         })
      end

      for i = 1, 9 do
        table.insert(keys, {
          mods = 'LEADER',
          key = tostring(i),
          action = wezterm.action.ActivateTab(i-1),
        })
      end

      wezterm.on('window-focus-changed', function(window, pane)
        local csi = window:is_focused() and '[I' or '[O'
        pane:send_text(csi)
      end)

      return {
        allow_square_glyphs_to_overflow_width = "Always",
        color_scheme = 'Tomorrow (dark) (terminal.sexy)',
        colors = colors,
        default_gui_startup_args = { 'connect', 'unix' },
        hide_tab_bar_if_only_one_tab = false,
        keys = keys,
        leader = { mods = 'CTRL', key = 'b' },
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
        force_reverse_video_cursor = true,
        native_macos_fullscreen_mode = true,
        tab_bar_at_bottom = true,
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
