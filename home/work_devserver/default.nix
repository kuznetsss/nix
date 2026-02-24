{
  home-manager,
  nixpkgs,
  util,
}:
let
  system = util.system.x86_64-linux;
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "skuznetsov";
      home.homeDirectory = /home/skuznetsov;
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;

      services.ssh-agent.enable = true;
      # programs.ssh.addKeysToAgent = "yes";
      services.gpg-agent.enable = true;
      services.gpg-agent.pinentry.package = pkgs.pinentry-tty;
    }
    ./../common/tmux.nix
    ./../common/wezterm.nix
    ./../common/zsh.nix
    ./../common/packages.nix
    ./../common/jujutsu.nix
    ./packages.nix
  ];
}
