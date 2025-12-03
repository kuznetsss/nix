#!/bin/bash

set -e

# Default values
CLEANUP=""
UPDATE_INPUTS=""
FLAKE_PATH="."
HOST_NAME=""

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [path_to_flake]#host

Deploy NixOS configuration to a remote host using flake deploy.nodes configuration.

Arguments:
  [path_to_flake]#host  Flake path and host name (defaults to current directory)
                        Examples: .#operator, /path/to/flake#ivan, #operator

Options:
  -c, --cleanup        Remove configuration directory after successful deployment
                       (overrides flake setting)
  -u, --update-inputs INPUT[,INPUT2,...]  
                       Update specific flake inputs before deployment.
                       Use 'all' to update all inputs, or comma-separated list.
                       (overrides flake setting)
                       Example: -u private-part,nixpkgs
  -h, --help           Display this help message

Examples:
  $0 .#operator
  $0 #ivan
  $0 -c .#operator
  $0 -u private-part .#operator
  $0 -u all -c .#ivan
EOF
    exit 1
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--cleanup)
            CLEANUP="true"
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
            # This should be the [path]#host argument
            if [ -z "${FLAKE_TARGET:-}" ]; then
                FLAKE_TARGET="$1"
            else
                echo "Error: Multiple target arguments provided"
                usage
            fi
            shift
            ;;
    esac
done

# Validate that we have a target
if [ -z "${FLAKE_TARGET:-}" ]; then
    echo "Error: Target not specified (format: [path]#host)"
    usage
fi

# Parse [path]#host format
if [[ "$FLAKE_TARGET" != *"#"* ]]; then
    echo "Error: Target must be in format [path]#host (e.g., .#operator)"
    usage
fi

FLAKE_PATH="${FLAKE_TARGET%%#*}"
HOST_NAME="${FLAKE_TARGET##*#}"

# Default to current directory if path is empty
if [ -z "$FLAKE_PATH" ]; then
    FLAKE_PATH="."
fi

if [ -z "$HOST_NAME" ]; then
    echo "Error: Host name not specified after '#'"
    usage
fi

echo "🔍 Reading configuration from flake for host: $HOST_NAME"

# Extract deploy configuration from flake
if ! command -v nix >/dev/null 2>&1; then
    echo "❌ Error: nix command not found"
    exit 1
fi

# Read deploy.nodes configuration for the specified host
FLAKE_USER=$(nix eval "${FLAKE_PATH}#deploy.nodes.${HOST_NAME}.user" --raw 2>/dev/null || echo "")
FLAKE_HOST=$(nix eval "${FLAKE_PATH}#deploy.nodes.${HOST_NAME}.host" --raw 2>/dev/null || echo "")
FLAKE_CLEANUP=$(nix eval "${FLAKE_PATH}#deploy.nodes.${HOST_NAME}.cleanup" --raw 2>/dev/null || echo "")
# update_inputs is an array in the flake, convert to comma-separated string
FLAKE_UPDATE_INPUTS=$(nix eval "${FLAKE_PATH}#deploy.nodes.${HOST_NAME}.update_inputs" --json 2>/dev/null | jq -r 'if type == "array" then join(",") else . end' 2>/dev/null || echo "")

# Validate that we found the host configuration (at minimum, host must be defined)
if [ -z "$FLAKE_HOST" ]; then
    echo "❌ Error: Could not find configuration for host '$HOST_NAME' in flake"
    echo "   Make sure deploy.nodes.$HOST_NAME.host exists in your flake.nix"
    exit 1
fi

# Apply defaults and allow CLI to override
# User: default to current user if not in flake
if [ -z "$CLEANUP" ]; then
    # CLI didn't override, use flake value or default to false
    if [ -z "$FLAKE_CLEANUP" ]; then
        CLEANUP="false"
    else
        CLEANUP="$FLAKE_CLEANUP"
    fi
fi

if [ -z "$UPDATE_INPUTS" ]; then
    # CLI didn't override, use flake value (can be empty)
    UPDATE_INPUTS="$FLAKE_UPDATE_INPUTS"
fi

# User: use flake value or default to current user
if [ -z "$FLAKE_USER" ]; then
    USER="$(whoami)"
else
    USER="$FLAKE_USER"
fi

REMOTE_HOST="$FLAKE_HOST"

echo "📝 Configuration:"
echo "   User: $USER"
echo "   Host: $REMOTE_HOST"
echo "   Cleanup: $CLEANUP"
if [ -n "$UPDATE_INPUTS" ]; then
    echo "   Update inputs: $UPDATE_INPUTS"
fi

# Setup cleanup trap if requested
if [ "$CLEANUP" = "true" ]; then
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
if ! nix flake check --no-build "${FLAKE_PATH}"; then
    echo "⚠️ Flake check failed locally"
    exit 1
fi

# Step 3: rsync flake directory to remote ~/nix
echo "📦 Syncing files..."
rsync -avz --delete "${FLAKE_PATH}/" "$USER@$REMOTE_HOST:~/nix/"

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
