{ nixpkgs }:
let forEachSystem = (import ./util { inherit nixpkgs; }).forEachSystem;
in forEachSystem (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
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
      nixos-rebuild switch \
        --flake ".#$HOST" \
        --target-host "$HOST" \
        --build-host "$HOST" \
        --sudo \
        --ask-sudo-password
    '';
  in {
    deploy = {
      type = "app";
      program = "${deployScript}";
      meta.description = "Push the current configuration to the host";
    };
  })
