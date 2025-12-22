{ ... }: {
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "localhost:51234";
      CREATE_ADMIN = 1;
      ADMIN_USERNAME = "admin";
    };
  };
}
