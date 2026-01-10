{ config, ... }:
let
  wg3Port = 49856;
in
{
  networking.nat = {
    enable = true;
    externalInterface = config.server_base.networkInterface;
    internalInterfaces = [ "wg3" ];
  };
  networking.firewall = {
    allowedUDPPorts = [ wg3Port ];
  };

  # Configure WireGuard with systemd-networkd
  systemd.network = {
    netdevs."50-wg3" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg3";
      };

      # publicKey: Nw9zxT3UPs5KNuXTQ/7aq0eXrYaCj0I+CIqqYJsxKQU=
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets."ivan/wg3_private_key".path;
        ListenPort = wg3Port;
      };
      wireguardPeers = [
        {
          # Phone
          PublicKey = "8sbt4kiqgNYT5U0B1eSMcm6hUtcfGghLbIB1xvfUpxM=";
          AllowedIPs = [ "10.0.30.5/32" ];
        }
        {
          # Evgenij
          PublicKey = "7cPu+YWpfxiRmy/9G/XYuJ8IiGlW3UuvxxmpY6s7W1w=";
          AllowedIPs = [ "10.0.30.7/32" ];
        }
        {
          # Anna
          PublicKey = "dYDGAIAHB2YM4rCYJP8YyelEdcQlP07mAe7uUyXJHws=";
          AllowedIPs = [ "10.0.30.8/32" ];
        }
        {
          # Router
          PublicKey = "cxtk0evE3XX8fscjceSuTk4iGhvly54K/ZFBy8boniA=";
          AllowedIPs = [ "10.0.30.9/32" ];
        }
      ];
    };

    networks."50-wg3" = {
      matchConfig.Name = "wg3";
      address = [ "10.0.30.1/24" ];
      networkConfig = {
        IPv4Forwarding = true;
      };
    };
  };
}





