{ agenix, private, ... }: {
  imports = [ agenix.nixosModules.default ];
  age.secrets = {
    "ivan/wg3_private_key" = {
      file = private.secretPath {
        host = "ivan";
        name = "wg3_private_key";
      };
      mode = "0440";
    };

    "ivan/coturn_auth_key" = {
      file = private.secretPath {
        host = "ivan";
        name = "coturn_auth_key";
      };
      mode = "0440";
      owner = "turnserver";
      group = "turnserver";
    };

  };
}
