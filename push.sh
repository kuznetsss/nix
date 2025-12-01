#!/bin/bash

set -e

# Default values
USER="$(whoami)"
CLEANUP=false
UPDATE_INPUTS=""

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [user@]host

Deploy NixOS configuration to a remote host.

Arguments:
  [user@]host          Remote host (optionally with user prefix, defaults to current user)

Options:
  -c, --cleanup        Remove configuration directory after successful deployment
  -u, --update-inputs INPUT[,INPUT2,...]  
                       Update specific flake inputs before deployment.
                       Use 'all' to update all inputs, or comma-separated list.
                       Example: -u private-part,nixpkgs
  -h, --help           Display this help message

Examples:
  $0 example.com
  $0 deployer@example.com
  $0 -c admin@example.com
  $0 -u private-part example.com
  $0 -u all -c deployer@example.com
EOF
    exit 1
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--cleanup)
            CLEANUP=true
            shift
            ;;
        -u|--update-inputs)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -u/--update-inputs requires an argument"
                usage
            fi
            UPDATE_INPUTS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            ;;
        *)
            # This should be the [user@]host argument
            if [ -z "${REMOTE_TARGET:-}" ]; then
                REMOTE_TARGET="$1"
            else
                echo "Error: Multiple host arguments provided"
                usage
            fi
            shift
            ;;
    esac
done

# Validate that we have a remote target
if [ -z "${REMOTE_TARGET:-}" ]; then
    echo "Error: Remote host not specified"
    usage
fi

# Parse user@host format
if [[ "$REMOTE_TARGET" == *@* ]]; then
    USER="${REMOTE_TARGET%%@*}"
    REMOTE_HOST="${REMOTE_TARGET##*@}"
else
    REMOTE_HOST="$REMOTE_TARGET"
fi

# Setup cleanup trap if requested
if [ "$CLEANUP" = true ]; then
    cleanup() {
        echo "🧹 Cleaning up remote configuration directory..."
        if ssh -t "$USER@$REMOTE_HOST" "rm -rf ~/nix" 2>/dev/null; then
            echo "✅ Cleanup successful!"
        else
            echo "⚠️ Cleanup failed"
        fi
    }
    trap cleanup EXIT
fi

echo "🚀 Pushing to $USER@$REMOTE_HOST"

# Step 1: Validate configuration locally (optional)
echo "🔍 Validating configuration locally..."
if command -v nix >/dev/null 2>&1; then
    if ! nix flake check --no-build ; then
        echo "⚠️ Flake check failed locally"
        exit 1
    fi
fi

# Step 3: rsync current directory to remote ~/nix
echo "📦 Syncing files..."
rsync -avz --delete ./ "$USER@$REMOTE_HOST:~/nix/"

# Step 4: Update flake inputs if specified
if [ -n "$UPDATE_INPUTS" ]; then
    if [ "$UPDATE_INPUTS" = "all" ]; then
        echo "🔄 Updating all flake inputs..."
        if ! ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && nix shell nixpkgs#git --command nix flake update"; then
            echo "❌ Failed to update flake inputs"
            exit 1
        fi
    else
        # Split comma-separated inputs
        IFS=',' read -ra INPUTS <<< "$UPDATE_INPUTS"
        for input in "${INPUTS[@]}"; do
            # Trim whitespace
            input=$(echo "$input" | xargs)
            echo "🔄 Updating flake input: $input..."
            if ! ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && nix shell nixpkgs#git --command nix flake update $input"; then
                echo "❌ Failed to update flake input: $input"
                exit 1
            fi
        done
    fi
fi

# Step 5: ssh to remote and build configuration
echo "🔨 Building configuration..."
if ! ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && sudo nixos-rebuild build --flake ."; then
    echo "❌ Build failed, stopping"
    exit 1
fi

# Step 6: Get current generation for rollback
echo "📋 Getting current generation..."
CURRENT_GEN=$(ssh -t "$USER@$REMOTE_HOST" "ls -la /nix/var/nix/profiles/system | awk '{print \$NF}' | grep -o '[0-9]*' | tail -1" 2>/dev/null | tr -d '\r')

# Step 7: ssh and activate configuration with sudo
echo "⚡ Activating configuration..."
if ! ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && sudo nixos-rebuild switch --flake ."; then
    echo "❌ Activation failed!"
    
    # Bonus: rollback if activation fails
    if [ -n "$CURRENT_GEN" ]; then
        echo "🔄 Rolling back to generation $CURRENT_GEN..."
        ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && sudo nixos-rebuild switch --rollback --flake ."
    fi
    exit 1
fi

echo "✅ Deployment successful!"
