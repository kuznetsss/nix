{ config, pkgs, ... }:
let wg3Port = 49856;
in {
  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = [ "wg3" ];
  };
  networking.firewall = { allowedUDPPorts = [ wg3Port ]; };

  networking.wireguard.interfaces = {
    wg3 = {
      ips = [ "10.0.30.1/24" ];
      listenPort = wg3Port;

      # publicKey Nw9zxT3UPs5KNuXTQ/7aq0eXrYaCj0I+CIqqYJsxKQU=
      privateKeyFile = config.age.secrets."ivan/wg3_private_key".path;

      peers = [
        {
          # Phone
          publicKey = "8sbt4kiqgNYT5U0B1eSMcm6hUtcfGghLbIB1xvfUpxM=";
          allowedIPs = [ "10.0.30.5/32" ];
        }
        {
          # Evgenij
          publicKey = "7cPu+YWpfxiRmy/9G/XYuJ8IiGlW3UuvxxmpY6s7W1w=";
          allowedIPs = [ "10.0.30.7/32" ];
        }
        {
          # Anna
          publicKey = "dYDGAIAHB2YM4rCYJP8YyelEdcQlP07mAe7uUyXJHws=";
          allowedIPs = [ "10.0.30.8/32" ];
        }
        {
          # Router
          publicKey = "cxtk0evE3XX8fscjceSuTk4iGhvly54K/ZFBy8boniA=";
          allowedIPs = [ "10.0.30.9/32" ];
        }
      ];
    };
  };

  # With networkd, use systemd service hooks instead of postSetup/postShutdown
  systemd.services."wireguard-wg3" = {
    postStart = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg3 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -o ens3 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -I POSTROUTING 1 -s 10.0.30.0/24 -o ens3 -j MASQUERADE
    '';
    postStop = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg3 -j ACCEPT || true
      ${pkgs.iptables}/bin/iptables -D FORWARD -o ens3 -j ACCEPT || true
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.30.0/24 -o ens3 -j MASQUERADE || true
    '';
  };
}

