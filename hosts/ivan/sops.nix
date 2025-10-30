{ sops-nix, ... }: {
  imports = [ sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
    secrets."ivan/wg3_private_key" = {
      mode = "0440";
      group = "root";
    };
    secrets."ivan/coturn_auth_key" = {
      mode = "0440";
      owner = "turnserver";
      group = "turnserver";
    };
  };
}
