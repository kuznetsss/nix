{ config, pkgs, ... }:
let
  networkInterface = config.server_base.networkInterface;
  webUIPort = 8096;
in
{
  services.jellyfin.enable = true;

  networking.firewall.interfaces.${networkInterface}.allowedTCPPorts = [ webUIPort ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime # OpenCL for tone mapping and filters (12th gen Alder Lake)
    ];
  };

  # Use iHD driver for VA-API
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}

