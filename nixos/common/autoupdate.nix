{ config, pkgs, lib, ... }@args:
let
  deployDir = "/var/lib/autoupdate";
  deployBranch = "deploy";
  repositoryUrl = "https://github.com/kuznetsss/nix.git";
  sshKeyPath = "/home/deployer/.ssh/id_ed25519";
  hostName = config.networking.hostName;

  updateScript = pkgs.writeShellScript "nixos-autoupdate" ''
    set -euo pipefail

    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ${sshKeyPath} -o StrictHostKeyChecking=accept-new"
    export NIX_SSHOPTS="-i ${sshKeyPath}"

    log() {
      echo "$*"
    }

    error() {
      echo "[ERROR] $*" >&2
    }

    success() {
      echo "[SUCCESS] $*"
    }

    warning() {
      echo "[WARNING] $*"
    }

    # Remove deploy directory if it exists
    if [ -d "${deployDir}" ]; then
      log "Removing existing deploy directory"
      ${pkgs.coreutils}/bin/rm -rf "${deployDir}"
    fi

    # Clone repository with only the deploy branch
    log "Cloning repository from ${repositoryUrl}"
    if ! ${pkgs.git}/bin/git clone --single-branch --branch ${deployBranch} --depth 1 "${repositoryUrl}" "${deployDir}"; then
      error "Failed to clone repository from ${repositoryUrl}"
      exit 1
    fi
    success "Repository cloned successfully"

    cd "${deployDir}"

    # Get hostname for building the correct configuration
    HOSTNAME="${hostName}"
    log "Building configuration for: $HOSTNAME"

    # Build new configuration
    if ! ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake ".#$HOSTNAME"; then
      error "Failed to build new configuration"
      exit 1
    fi
    success "Build successful"

    RUNNING_KERNEL_VERSION=$(${pkgs.coreutils}/bin/uname -r)

    # Try to activate the new configuration
    log "Attempting to activate new configuration"
    if ! ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ".#$HOSTNAME"; then
      error "Failed to activate new configuration"
      if ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --rollback; then
        success "Rollback successful"
      else
        error "Rollback failed - system may be in inconsistent state"
      fi
      exit 1
    fi

    success "Successfully updated and activated new configuration"

    NEW_KERNEL=$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system/kernel)
    NEW_KERNEL_VERSION=$(echo "$NEW_KERNEL" | ${pkgs.gnused}/bin/sed -n 's/.*linux-\([0-9.]*\).*/\1/p')
    log "New system kernel: $NEW_KERNEL_VERSION"
    if [ "$RUNNING_KERNEL_VERSION" != "$NEW_KERNEL_VERSION" ]; then
      log "Kernel version changed: $RUNNING_KERNEL_VERSION -> $NEW_KERNEL_VERSION"
      ${pkgs.systemd}/bin/shutdown -r +1 "System will reboot in 1 minute to apply updates"
    else
      log "No reboot required - kernel version unchanged"
    fi

    log "Autoupdate completed successfully"
    exit 1
  '';
in {
  imports = [ (import ./send_to_telegram.nix args) ];

  options = {
    modules.autoupdate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable pull based autoupdate";
      };
      notifyOnFailure = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Send telegram bot notification on failure";
      };
    };
  };

  config = lib.mkIf config.modules.autoupdate.enable (lib.mkMerge [
    {
      systemd.services.nixos-autoupdate = {
        enable = true;
        description = "NixOS automatic update from deploy branch";
        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = "${updateScript}";
          WorkingDirectory = "/var/lib";
          Restart = "no";
          StandardOutput = "journal";
          StandardError = "journal";
        };
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };

      systemd.timers.nixos-autoupdate = {
        description = "Timer for NixOS automatic updates";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = false;
          RandomizedDelaySec = "5min";
        };
      };
    }

    (lib.mkIf config.modules.autoupdate.notifyOnFailure {
      systemd.services.nixos-autoupdate.onFailure =
        [ "nixos-autoupdate-failure-notify.service" ];

      systemd.services.nixos-autoupdate-failure-notify = {
        description = "Send Telegram notification on autoupdate failure";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = ''
            ${config.modules.telegram-notify.script} -s "⚠️ NixOS autoupdate failed on the host `${hostName}`"'';
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
