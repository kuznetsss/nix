{ config, pkgs, private, ... }:
let
  webUIPort = 8080;
  torrentingPort = private.network.batou.torrentingPort;
  networkInterface = config.server_base.networkInterface;
  vpnInterface = config.vpn.interface;
  vpnNamespace = config.vpn.namespace;
in {
  services.qbittorrent = {
    enable = true;
    webuiPort = webUIPort;
    inherit torrentingPort;
  };

  systemd.services."qbittorrent-firewall" = {
    after = [ "${vpnInterface}-connection.service" ];
    bindsTo = [ "${vpnInterface}-connection.service" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "add-qbt-fw" ''
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -i ${vpnInterface} -p tcp --dport ${
          toString torrentingPort
        } -j ACCEPT
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -i ${vpnInterface} -p udp --dport ${
          toString torrentingPort
        } -j ACCEPT
      '';
      ExecStop = pkgs.writeShellScript "del-qbt-fw" ''
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} ${pkgs.iptables}/bin/iptables -D INPUT -i ${vpnInterface} -p tcp --dport ${
          toString torrentingPort
        } -j ACCEPT
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} ${pkgs.iptables}/bin/iptables -D INPUT -i ${vpnInterface} -p udp --dport ${
          toString torrentingPort
        } -j ACCEPT
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services.qbittorrent = {
    requires =
      [ "qbittorrent-firewall.service" "${vpnInterface}-connection.service" ];
    after =
      [ "qbittorrent-firewall.service" "${vpnInterface}-connection.service" ];
    bindsTo = [ "${vpnInterface}-connection.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/${vpnNamespace}";
      BindReadOnlyPaths =
        "/etc/netns/${vpnNamespace}/resolv.conf:/etc/resolv.conf";
    };
  };

  # Socket listens for a connection on the port and on each connection start a service with the same name
  systemd.sockets.qbittorrent-proxy = {
    description = "qBittorrent proxy socket";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "${toString webUIPort}" ];
  };

  # systemd-socket-proxyd takes socket from systemd as input and forwards everything from it to the address provided in args
  systemd.services.qbittorrent-proxy = {
    description = "qBittorrent proxy to VPN namespace";
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${
          toString webUIPort
        }";
      PrivateNetwork = true;
      NetworkNamespacePath = "/var/run/netns/${vpnNamespace}";
    };
  };

  # Take torrentingPort on the main namespace
  systemd.sockets.dummy-socket = {
    description = "Dummy socket for port reservation";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "${toString torrentingPort}" ]; # TCP
    listenDatagrams = [ "${toString torrentingPort}" ]; # UDP
    socketConfig.Accept = false;
  };

  # Dummy service that does nothing (required by systemd)
  systemd.services.dummy-socket = {
    description = "Dummy service for port reservation";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };

  networking.firewall = {
    interfaces.${networkInterface}.allowedTCPPorts = [ webUIPort ];
    extraCommands = ''
      iptables -A OUTPUT -p tcp -o ${networkInterface} --sport ${torrentingPort} -j REJECT
      iptables -A OUTPUT -p udp -o ${networkInterface} --sport ${torrentingPort} -j REJECT
    '';
  };
}

