{ config, pkgs, ... }:
let
  webUIPort = 8080;
in {
  services.qbittorrent = {
    enable = true;
    webuiPort = webUIPort;
  };

  systemd.services.qbittorrent = {
    requires = [ "wg0-setup.service" ];
    after = [ "wg0-setup.service" ];
    bindsTo = [ "wg0-setup.service" ];
    serviceConfig.NetworkNamespacePath =
      "/var/run/netns/${config.vpnNamespace}";
  };

  # Create a reverse proxy to access qBittorrent from the host using systemd-socket-proxyd
  systemd.sockets.qbittorrent-proxy = {
    description = "qBittorrent proxy socket";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "${toString webUIPort}" ];
  };

  systemd.services.qbittorrent-proxy = {
    description = "qBittorrent proxy to VPN namespace";
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString webUIPort}";
      PrivateNetwork = true;
      NetworkNamespacePath = "/var/run/netns/${config.vpnNamespace}";
    };
  };

  # Open firewall for web UI access
  networking.firewall.allowedTCPPorts = [ webUIPort ];
}
