{ config, lib, ... }:
let hostName = config.networking.hostName;
in {
  imports = [ ./send_to_telegram.nix ];

  options = {
    server_base.autoupdate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable pull based autoupdate from deploy branch";
      };
      notifyOnFailure = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Send telegram bot notification on failure";
      };
      operation = lib.mkOption {
        type = lib.types.enum [ "switch" "boot" ];
        default = "switch";
        description =
          "Whether to use 'switch' (immediate) or 'boot' (on next reboot)";
      };
    };
  };

  config = lib.mkIf config.server_base.autoupdate.enable (lib.mkMerge [
    {
      # Use the upstream NixOS auto-upgrade module
      system.autoUpgrade = {
        enable = true;

        # Point to the deploy branch of the repository
        flake = "github:kuznetsss/nix/deploy#${hostName}";

        # Choose operation mode (switch or boot)
        operation = config.server_base.autoupdate.operation;

        # Don't update flake.lock, use the locked versions from deploy branch
        upgrade = false;

        # Schedule settings
        dates = "03:30:00";
        randomizedDelaySec = "5min";
        persistent = false;
        allowReboot = true;
      };
    }

    (lib.mkIf config.server_base.autoupdate.notifyOnFailure {
      # Hook failure notification to the upstream service
      systemd.services.nixos-upgrade.onFailure =
        [ "nixos-autoupdate-failure-notify.service" ];

      systemd.services.nixos-autoupdate-failure-notify = {
        description = "Send Telegram notification on autoupdate failure";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = ''
            ${config.server_base.telegram-notify.script} -s "⚠️ NixOS autoupdate failed on the host `${hostName}`"'';
          TimeoutStartSec = "2s";
          Restart = "on-failure";
          RestartSec = "1s";
          StartLimitBurst = 3;
          StartLimitIntervalSec = 0;
        };
      };
    })
  ]);
}
