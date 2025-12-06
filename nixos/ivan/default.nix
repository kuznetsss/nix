{ nixpkgs, home-manager, sops-nix, private }:
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit sops-nix private; };
  modules = [
    ./sops.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./wireguard.nix
    ./prosody.nix
    ./logrotate.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.sergey = { ... }: {
        home.stateVersion = "25.11";
        imports = [ ../../home/common/zsh.nix ];
      };
    }
  ];
}
