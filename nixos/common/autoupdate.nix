{ pkgs, ... }:
let
  deployUser = "deployer";
  deployDir = "/home/${deployUser}/autoupdate";
  deployBranch = "deploy";
  repositoryUrl = "https://github.com/kuznetsss/nix.git";

  updateScript = pkgs.writeShellScript "nixos-autoupdate" ''
    set -euo pipefail

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
    if ! ${pkgs.util-linux}/bin/runuser -u deployer -- ${pkgs.git}/bin/git clone --single-branch --branch ${deployBranch} --depth 1 "${repositoryUrl}" "${deployDir}"; then
      error "Failed to clone repository from ${repositoryUrl}"
      exit 1
    fi
    success "Repository cloned successfully"

    cd "${deployDir}"

    # Get hostname for building the correct configuration
    HOSTNAME=$(${pkgs.hostname}/bin/hostname)
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
  '';
in {
  # Systemd service for automatic updates
  systemd.services.nixos-autoupdate = {
    description = "NixOS automatic update from deploy branch";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      # Allow the deploy user to run nixos-rebuild with sudo
      ExecStart = "${updateScript}";
      # Set working directory
      WorkingDirectory = "/home/${deployUser}";
      # Restart on failure
      Restart = "no";
      # Logging
      StandardOutput = "journal";
      StandardError = "journal";
    };
    # Ensure git and network are available
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  # Timer to run the service every night at 4 AM UTC
  systemd.timers.nixos-autoupdate = {
    description = "Timer for NixOS automatic updates";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Run at 4 AM UTC every day
      OnCalendar = "*-*-* 04:00:00";
      # Use UTC timezone
      # If the system was down at the scheduled time, run on next boot
      Persistent = false;
      # Add some randomization to avoid all servers updating at once (0-5 minutes)
      RandomizedDelaySec = "5min";
    };
  };
}
