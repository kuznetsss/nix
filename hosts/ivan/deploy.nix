{ self, deploy-rs }:
let
  system = self.nixosConfigurations.ivan.config.nixpkgs.hostPlatform.system;
in
{
  hostname = "ivan";
  remoteBuild = true;
  magicRollback = true;
  interactiveSudo = false;
  profiles.system = {
    user = "root";
    sshUser = "root";
    sshOpts = [ "-p" "21587" ];

    path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.ivan;
  };
}

