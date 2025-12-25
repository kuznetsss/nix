{ pkgs, ... }:
let
  vpnNamespace = "wg0-vpn";
  interfaceName = "wg0";
  configFile = "/etc/wireguard/wg0.conf";
  addressFile = "/etc/wireguard/wg0_address";
  dnsFile = "/etc/wireguard/wg0_dns";
in {
  systemd.services."netns-${vpnNamespace}" = {
    description = "${vpnNamespace} network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "netns-up" ''
        set -euo pipefail

        ${pkgs.iproute2}/bin/ip netns add ${vpnNamespace}
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
          ${pkgs.iproute2}/bin/ip link set lo up
      '';
      ExecStop = "${pkgs.iproute2}/bin/ip netns del ${vpnNamespace}";
    };
  };

  systemd.services.wg0-setup = {
    description = "WireGuard interface ${interfaceName} in ${vpnNamespace}";
    requires = [ "netns-${vpnNamespace}.service" "network-online.target" ];
    after = [ "netns-${vpnNamespace}.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = pkgs.writeShellScript "check-wg-config" ''
        if [ ! -f ${configFile} ]; then
          echo "Error: ${configFile} does not exist"
          echo "Create the configuration file with your WireGuard settings."
          exit 1
        fi
        if [ ! -f ${addressFile} ]; then
          echo "Error: ${addressFile} does not exist"
          echo "Create a file with your WireGuard addresses (comma-separated)."
          exit 1
        fi
      '';
      ExecStart = pkgs.writeShellScript "wg-up" ''
        set -euo pipefail

          # Read Address and DNS from separate files
          ADDRESSES=$(${pkgs.coreutils}/bin/cat ${addressFile} | ${pkgs.coreutils}/bin/tr -d ' \n')
          DNS=$(${pkgs.coreutils}/bin/cat ${dnsFile} 2>/dev/null | ${pkgs.coreutils}/bin/tr -d ' \n' || true)

          # Create WireGuard interface in namespace
          ${pkgs.iproute2}/bin/ip link add ${interfaceName} type wireguard
          ${pkgs.iproute2}/bin/ip link set ${interfaceName} netns ${vpnNamespace}

          # Configure interface in namespace (config should not have Address/DNS lines)
          ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
            ${pkgs.wireguard-tools}/bin/wg setconf ${interfaceName} ${configFile}

          # Add all addresses (comma-separated)
          IFS=',' read -ra ADDR_ARRAY <<< "$ADDRESSES"
          for addr in "''${ADDR_ARRAY[@]}"; do
            ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
              ${pkgs.iproute2}/bin/ip addr add "$addr" dev ${interfaceName}
          done

          ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} up

          # Add default route through interface
          ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
            ${pkgs.iproute2}/bin/ip route add default dev ${interfaceName}

        # Set DNS in namespace if present
        if [ -n "$DNS" ]; then
          ${pkgs.coreutils}/bin/mkdir -p /etc/netns/${vpnNamespace}
          echo "nameserver $DNS" > /etc/netns/${vpnNamespace}/resolv.conf
        fi
      '';
      ExecStop = pkgs.writeShellScript "wg-down" ''
        ${pkgs.iproute2}/bin/ip netns exec ${vpnNamespace} \
          ${pkgs.iproute2}/bin/ip link del ${interfaceName}
      '';
    };
  };
}

