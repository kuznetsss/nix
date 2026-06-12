{
  home-manager,
  nixpkgs,
  util,
}:
let
  system = util.system.aarch64-darwin;
  pkgs = nixpkgs.legacyPackages.${system};
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    rec {
      home.username = "skuznetsov";
      home.homeDirectory = "/Users/skuznetsov";
      home.stateVersion = "26.05";
      nixpkgs.config = {
        allowUnfree = true;
      };
      programs = {
        home-manager.enable = true;
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
        neovide = {
          enable = true;
          settings = {
            font = {
              normal = "JetBrainsMono Nerd Font";
              size = 14;
            };
            neovim-bin = "${pkgs.neovim}/bin/nvim";
            chdir = "${home.homeDirectory}/Documents";
            srgb = true;
          };
        };
      };
    }
    ./../common/diff_on_activation.nix
    ./../common/tmux.nix
    ./../common/wezterm.nix
    ./../common/zsh.nix
    ./../common/packages.nix
    ./../common/jujutsu.nix
    ./packages.nix
  ];
}
