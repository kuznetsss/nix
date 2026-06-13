{
  config,
  pkgs,
  ...
}:
{
  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = "JetBrainsMono Nerd Font";
        size = 14;
      };
      neovim-bin = "${pkgs.neovim}/bin/nvim";
      chdir = "${config.home.homeDirectory}/Documents";
      srgb = true;
      fork = true;
    };
  };
}
