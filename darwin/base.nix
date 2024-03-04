{ nix-darwin, nixpkgs, util }:
let
  system = util.system.aarch64-darwin;
  pkgs = nixpkgs.legacyPackages.${system};
in
nix-darwin.lib.darwinSystem {
  inherit system;
  modules = [
    {
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";
      nix.gc.automatic = true;
      nix.gc.interval = { Day = 3; };

      security.pam.enableSudoTouchIdAuth = true;

      # Set Git commit hash for darwin-version.
      # system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    }
  ];
}
