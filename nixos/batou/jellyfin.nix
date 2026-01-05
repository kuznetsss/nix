{ config, ... }:
let
  networkInterface = config.server_base.networkInterface;
  webUIPort = 8096;
in {
  services.jellyfin.enable = true;
  networking.firewall.interfaces.${networkInterface}.allowedTCPPorts =
    [ webUIPort ];
}
