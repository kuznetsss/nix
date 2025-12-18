{ nixpkgs, home-manager, agenix, private, ... }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit agenix private; };
  modules = [
    ./hardware-configuration.nix

    ../common/core_server.nix
    {
      networking.hostName = "ivan";
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vda";
      boot.kernel.sysctl = { "net.ipv4.tcp_fastopen" = 3; };
    }

    ./wireguard.nix
    ./prosody.nix
    ./logrotate.nix
    ./secrets.nix

    home-manager.nixosModules.home-manager
    (import ../../home/common/base.nix)
  ];
}
