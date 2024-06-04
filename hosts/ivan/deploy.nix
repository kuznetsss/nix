{ self, deploy-rs }:
let
  system = self.nixosConfigurations.ivan.config.nixpkgs.hostPlatform.system;
in
{
  hostname = "ivan";
  remoteBuild = true;
  magicRollback = true;
  interactiveSudo = true;
  profiles.system = {
    user = "root";
    sshUser = "sergey";
    sshOpts = [ "-p" "21587" ];

    path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.ivan;
  };
}

