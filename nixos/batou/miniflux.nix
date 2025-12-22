{ config, agenix, private, ... }:
let networkInterface = config.server_base.networkInterface;
in {
  imports = [ agenix.nixosModules.default ];
  age.secrets = {
    "batou/miniflux_admin" = {
      file = private.secretPath {
        host = "batou";
        name = "miniflux_admin";
      };
      owner = config.systemd.services.miniflux.serviceConfig.User;
      group = "root";
    };

  };
  services.miniflux = {
    enable = true;
    config.LISTEN_ADDR = "0.0.0.0:51234";
    adminCredentialsFile = config.age.secrets."batou/miniflux_admin".path;
  };
  networking.firewall.interfaces = {
    ${networkInterface}.allowedTCPPorts = [ 51234 ];
    tailscale0.allowedTCPPorts = [ 51234 ];
  };
}
