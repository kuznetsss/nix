{
  config,
  agenix,
  private,
  ...
}:
let
  networkInterface = config.server_base.networkInterface;
in
{
  imports = [ agenix.nixosModules.default ];
  users.groups.miniflux-secrets = { };
  age.secrets = {
    "batou/miniflux_admin" = {
      file = private.secretPath {
        host = "batou";
        name = "miniflux_admin";
      };
      group = "miniflux-secrets";
      mode = "0440";
    };
  };
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:51234";
      POLLING_PARSING_ERROR_LIMIT = 0;
      POLLING_FREQUENCY = 30;
    };
    adminCredentialsFile = config.age.secrets."batou/miniflux_admin".path;
  };
  systemd.services.miniflux.serviceConfig.SupplementaryGroups = [ "miniflux-secrets" ];
  networking.firewall.interfaces.${networkInterface}.allowedTCPPorts = [ 51234 ];
}
