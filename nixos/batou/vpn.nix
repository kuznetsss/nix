{ config, pkgs, lib, ... }:
let
  interfaceName = "wg0";
  configFile = "/etc/wireguard/wg0.conf";
  addressFile = "/etc/wireguard/wg0_address";
  dnsFile = "/etc/wireguard/wg0_dns";
in {
  options.vpnNamespace = lib.mkOption {
    type = lib.types.str;
    default = "wg0-vpn";
    description = "VPN namespace name";
  };
  config = {
    systemd.services."netns-${config.vpnNamespace}" = {
      description = "${config.vpnNamespace} network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "netns-up" ''
          set -euo pipefail

          ${pkgs.iproute2}/bin/ip netns add ${config.vpnNamespace}
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
            ${pkgs.iproute2}/bin/ip link set lo up

          # Setup firewall
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -P INPUT DROP
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -i lo -j ACCEPT
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -P FORWARD DROP

          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -P OUTPUT DROP
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A OUTPUT -o lo -j ACCEPT
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        '';
        ExecStop = pkgs.writeShellScript "netns-down" ''
          set -euo pipefail

          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -X
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -F
          ${pkgs.iproute2}/bin/ip netns del ${config.vpnNamespace}
        '';
      };
    };

    systemd.services.wg0-setup = {
      description =
        "WireGuard interface ${interfaceName} in ${config.vpnNamespace}";
      requires =
        [ "netns-${config.vpnNamespace}.service" "network-online.target" ];
      after =
        [ "netns-${config.vpnNamespace}.service" "network-online.target" ];
      bindsTo = [ "netns-${config.vpnNamespace}.service" ];
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
          ${pkgs.iproute2}/bin/ip link set ${interfaceName} netns ${config.vpnNamespace}

          # Configure interface in namespace (config should not have Address/DNS lines)
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
            ${pkgs.wireguard-tools}/bin/wg setconf ${interfaceName} ${configFile}

          # Add all addresses (comma-separated)
          IFS=',' read -ra ADDR_ARRAY <<< "$ADDRESSES"
          for addr in "''${ADDR_ARRAY[@]}"; do
            ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
              ${pkgs.iproute2}/bin/ip addr add "$addr" dev ${interfaceName}
          done

          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
            ${pkgs.iproute2}/bin/ip link set ${interfaceName} up

          # Add default route through interface
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
            ${pkgs.iproute2}/bin/ip route add default dev ${interfaceName}

          # Set DNS in namespace if present
          if [ -n "$DNS" ]; then
            ${pkgs.coreutils}/bin/mkdir -p /etc/netns/${config.vpnNamespace}
            echo "nameserver $DNS" > /etc/netns/${config.vpnNamespace}/resolv.conf
          fi

          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} ${pkgs.iptables}/bin/iptables -A OUTPUT -o ${interfaceName} -j ACCEPT
        '';
        ExecStop = pkgs.writeShellScript "wg-down" ''
          ${pkgs.iproute2}/bin/ip netns exec ${config.vpnNamespace} \
            ${pkgs.iproute2}/bin/ip link del ${interfaceName}
        '';
      };
    };
  };
}



