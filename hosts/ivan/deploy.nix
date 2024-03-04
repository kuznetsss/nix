{ deploy-rs, self }:
{
  hostname = "ivan";
  remoteBuild = true;
  magicRollback = true;
  interactiveSudo = true;
  profiles.system = {
    user = "root";
    sshUser = "sergey";
    sshOpts = [ "-p" "2587" ];

    path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.ivan;
  };
}

