{ ... }: {
  services.miniflux = {
    enable = true;
    config.LISTEN_ADDR = "localhost:51234";
    adminCredentialsFile = "/etc/nixos/miniflux-admin-credentials";
  };
}
