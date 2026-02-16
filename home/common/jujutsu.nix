{ ... }:
{
  programs.jujutsu.enable = true;
  home.file = {
    ".config/jjui/config.toml".text = ''
      [keys]
      force_apply = ["ctrl+enter"]

      [ui]
      theme = "my-theme"
    '';
    ".config/jjui/themes/my-theme.toml".text = ''
      "revisions selected" = { bg = "#404040"}
    '';
  };
}
