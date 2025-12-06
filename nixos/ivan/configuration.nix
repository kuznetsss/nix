{ pkgs, lib, private, ... }:
lib.mkMerge [
  (import ../common/core_server.nix {
    inherit pkgs private;
    hostName = "ivan";
  })

  {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";
    boot.kernel.sysctl = { "net.ipv4.tcp_fastopen" = 3; };
  }
]
