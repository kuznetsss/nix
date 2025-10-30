{ ... }: {
  services.logrotate.settings = {
    nginx.enable = false;
    header = {
      daily = true;
      rotate = 7;
      create = true;
      dateext = true;
    };
    "/var/log/fail2ban.log" = { size = "25M"; };
    "/var/lib/prosody/log*" = {
      size = "25M";
      su = "prosody prosody";
    };
    "/var/log/nginx/*.log" = {
      rotate = 7;
      size = "25M";
      postrotate = "[ ! -f /var/run/nginx/nginx.pid ] || kill -USR1 `cat /var/run/nginx/nginx.pid`";
      su = "nginx nginx";
    };
  };
}
