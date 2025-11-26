#!/bin/bash

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <remote_host> [user]"
    exit 1
fi

REMOTE_HOST="$1"
USER="${2:-deployer}"

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

# Step 4: Update private-part input
echo "🔄 Updating private-part input..."
if ! ssh -t "$USER@$REMOTE_HOST" "cd ~/nix && nix shell nixpkgs#git --command nix flake update private-part"; then
    echo "❌ Failed to update private-part input"
    exit 1
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
        ssh -t "$USER@$REMOTE_HOST" "sudo nixos-rebuild switch --rollback --flake ."
    fi
    exit 1
fi

echo "✅ Deployment successful!"
