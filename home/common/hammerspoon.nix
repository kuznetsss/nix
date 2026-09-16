{ config, lib, ... }:
let
  cfg = config.home_base.hammerspoon;

  bindApp = key: bundle_id: "hs.hotkey.bind(mod_key, '${key}', focus '${bundle_id}')";
in
{
  options.home_base.hammerspoon = {
    modKey = lib.mkOption {
      type = lib.types.str;
      default = "alt";
      description = "Modifier used for all hotkeys.";
    };

    appHotkeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        w = "com.github.wez.wezterm";
        m = "com.spotify.client";
      };
      example = {
        s = "com.tinyspeck.slackmacgap";
      };
      description = "Key to bundle id of the application to launch or focus.";
    };

    browserHotkey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "b";
      description = "Key to focus the default https handler, or null to not bind one.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Lua appended to init.lua.";
    };
  };

  config.home.file.".hammerspoon/init.lua".text = ''
    local mod_key = '${cfg.modKey}'

    local function focus(bundle_id)
        return function()
            hs.application.launchOrFocusByBundleID(bundle_id)
        end
    end

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList bindApp cfg.appHotkeys)}
  ''
  + lib.optionalString (cfg.browserHotkey != null) ''

    local browser
    hs.hotkey.bind(mod_key, '${cfg.browserHotkey}', function()
        if not browser then
            browser = hs.urlevent.getDefaultHandler 'https'
        end
        hs.application.launchOrFocusByBundleID(browser)
    end)
  ''
  + lib.optionalString (cfg.extraConfig != "") ''

    ${cfg.extraConfig}
  ''
  + ''

    -- Machine local config kept out of the repo
    local local_config = hs.configdir .. '/local.lua'
    if hs.fs.attributes(local_config) then
        dofile(local_config)
    end
  '';
}
