{ sops-nix, ... }:
{
  imports = [
    sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
  };
}
