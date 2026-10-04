{ nixpkgs, nixpkgs-stable }:
let
  forEachSystem = (import ./util { inherit nixpkgs; }).forEachSystem;
in
forEachSystem (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    # nixos-rebuild must match the hosts' release (nixos-26.05), not unstable.
    # Unstable's nixos-rebuild-ng passes `systemd-run --output=cat`, which the
    # hosts' systemd 260 doesn't support, so the switch step fails. Its re-exec
    # into the target's own nixos-rebuild can't save us either: from darwin it
    # always fails (wrong OS/arch) and falls back to the local copy.
    # Revisit once the hosts move to a systemd that supports --output.
    nixos-rebuild = nixpkgs-stable.legacyPackages.${system}.nixos-rebuild;
    deployScript = pkgs.writeShellScript "deploy" ''
      set -euo pipefail

      if [ $# -eq 0 ]; then
        echo "Usage: nix run .#deploy <hostname>"
        echo "Available hosts:"
        ${pkgs.nix}/bin/nix flake show --json | ${pkgs.jq}/bin/jq -r '.nixosConfigurations | keys[]'
        exit 1
      fi

      HOST="$1"

      echo "Running flake checks..."
      ${pkgs.nix}/bin/nix flake check --no-build --all-systems --show-trace

      echo "Deploying to $HOST..."
      ${nixos-rebuild}/bin/nixos-rebuild switch \
        --flake ".#$HOST" \
        --target-host "$HOST" \
        --build-host "$HOST" \
        --use-substitutes \
        --option http-connections 50 \
        --sudo \
        --ask-sudo-password
    '';
  in
  {
    deploy = {
      type = "app";
      program = "${deployScript}";
      meta.description = "Push the current configuration to the host";
    };
  }
)
