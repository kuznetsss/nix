{ home-manager, nixpkgs, util }:
let
  system = util.system.x86_64-linux;
  pkgs = nixpkgs.legacyPackages.${system};
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "skuznetsov";
      home.homeDirectory = /home/skuznetsov;
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;

      services.ssh-agent.enable = true;
      programs.ssh.addKeysToAgent = "yes";
      services.gpg-agent.enable = true;
      services.gpg-agent.pinentryPackage = pkgs.pinentry-tty;
    }
    ./../tmux.nix
    ./../wezterm.nix
    ./../zsh.nix
    ./../packages.nix
    ./packages.nix
  ];
}
