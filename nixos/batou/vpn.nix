{ config, pkgs, lib, ... }:
let
  vpnInterface = config.vpn.interface;
  namespace = config.vpn.namespace;
  configFile = "/etc/wireguard/${vpnInterface}.conf";
  addressFile = "/etc/wireguard/${vpnInterface}_address";
  dnsFile = "/etc/wireguard/${vpnInterface}_dns";
in {
  options.vpn = {
    namespace = lib.mkOption {
      type = lib.types.str;
      default = "wg0vpn";
      description = "VPN namespace name";
    };
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "VPN interface name";
    };
  };
  config = {
    systemd.services."netns@" = {
      description = "%I network namespace";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${
            pkgs.writeShellScript "netns-up" ''
              set -euo pipefail
              NAMESPACE="$1"

              ${pkgs.iproute2}/bin/ip netns add "$NAMESPACE"
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iproute2}/bin/ip link set lo up

              # Disable IPv6 in namespace
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.disable_ipv6=1
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.disable_ipv6=1

              # Setup IPv4 firewall
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -P INPUT DROP
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -A INPUT -i lo -j ACCEPT
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -P FORWARD DROP

              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -P OUTPUT DROP
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -A OUTPUT -o lo -j ACCEPT
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

              # Setup IPv6 firewall (block everything as defense in depth)
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/ip6tables -P INPUT DROP
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/ip6tables -P FORWARD DROP
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/ip6tables -P OUTPUT DROP
            ''
          } %I";
        ExecStop = "${
            pkgs.writeShellScript "netns-down" ''
              set -euo pipefail
              NAMESPACE="$1"

              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -X
              ${pkgs.iproute2}/bin/ip netns exec "$NAMESPACE" ${pkgs.iptables}/bin/iptables -F
              ${pkgs.iproute2}/bin/ip netns del "$NAMESPACE"
            ''
          } %I";
      };
    };

    systemd.services."${vpnInterface}-connection" = {
      description =
        "WireGuard connection ${config.vpn.interface} in ${namespace} namespace";
      requires = [ "netns@${namespace}.service" "network-online.target" ];
      after = [ "netns@${namespace}.service" "network-online.target" ];
      bindsTo = [ "netns@${namespace}.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = pkgs.writeShellScript "check-wg-config" ''
          set -euo pipefail
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
          ${pkgs.iproute2}/bin/ip link add ${vpnInterface} type wireguard
          ${pkgs.iproute2}/bin/ip link set ${vpnInterface} netns ${namespace}

          # Configure interface in namespace (config should not have Address/DNS lines)
          ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
            ${pkgs.wireguard-tools}/bin/wg setconf ${vpnInterface} ${configFile}

          # Add all addresses (comma-separated)
          IFS=',' read -ra ADDR_ARRAY <<< "$ADDRESSES"
          for addr in "''${ADDR_ARRAY[@]}"; do
            ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
              ${pkgs.iproute2}/bin/ip addr add "$addr" dev ${vpnInterface}
          done

          ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
            ${pkgs.iproute2}/bin/ip link set ${vpnInterface} up

          # Add default route through interface
          ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
            ${pkgs.iproute2}/bin/ip route add default dev ${vpnInterface}

          # Set DNS in namespace if present
          if [ -n "$DNS" ]; then
            ${pkgs.coreutils}/bin/mkdir -p /etc/netns/${namespace}
            echo "nameserver $DNS" > /etc/netns/${namespace}/resolv.conf
          fi

          ${pkgs.iproute2}/bin/ip netns exec ${namespace} ${pkgs.iptables}/bin/iptables -A OUTPUT -o ${vpnInterface} -j ACCEPT
        '';
        ExecStop = pkgs.writeShellScript "wg-down" ''
          ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
            ${pkgs.iproute2}/bin/ip link del ${vpnInterface}
        '';
      };
    };
  };
}

