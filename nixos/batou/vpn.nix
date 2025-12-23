{ config, ... }: {
  systemd.network = {
    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [ ];
    };
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };

      wireguardConfig = {
        ListenPort = 51820;

        # ensure file is readable by `systemd-network` user
        PrivateKeyFile = config.age.secrets.wg-key-vps.path;

        # To automatically create routes for everything in AllowedIPs,
        # add RouteTable=main
        RouteTable = "main";

        # FirewallMark marks all packets send and received by wg0 
        # with the number 42, which can be used to define policy rules on these packets. 
        FirewallMark = 42;
      };
      wireguardPeers = [{
        PublicKey = "";
        AllowedIPs = [ ];
        Endpoint = "";
      }];
    };
  };
}
