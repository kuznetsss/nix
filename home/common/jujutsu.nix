{ pkgs, ... }:
{
  programs.jujutsu.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      jjui = prev.jjui.overrideAttrs (oldAttrs: {
        src = prev.fetchFromGitHub {
          owner = "idursun";
          repo = "jjui";
          rev = "83468d014564e5824b7ccf869e0b2309ae7b065c";
          hash = "sha256-CBNMoVALCLWQ9bsrQilnx8djLufLNt8p9iK+HnpUPgc=";
        };
        doCheck = false;
      });
    })
  ];

  home.file = {
    ".config/jjui/config.toml".text = ''
      [keys]
      force_apply = ["ctrl+enter"]

      [ui]
      theme = "everforest"
    '';
    ".config/jjui/themes/everforest.toml".text = ''
      # "text"      = { fg = "#d3c6aa", bg = "#2d353b" }
      "dimmed"    = { fg = "#859289", bg = "#2d353b" }
      "title"     = { fg = "#7fbbb3", bold = true }
      "shortcut"  = { fg = "#d699b6" }
      "matched"   = { fg = "#dbbc7f" }
      "border"    = { fg = "#859289" }
      "selected"  = { bg = "#343f44", fg = "#d3c6aa", bold = true }

      "source_marker" = { bg = "#83c092", fg = "#2d353b", bold = true }
      "target_marker" = { bg = "#a7c080", fg = "#2d353b", bold = true }

      "status" = { bg = "#343f44" }
      "status title" = { fg = "#2d353b", bg = "#7fbbb3", bold = true }

      "revset title" = { fg = "#7fbbb3", bold = true }
      "revset text" = { fg = "#d3c6aa", bold = true }
      "revset completion text" = { fg = "#d3c6aa" }
      "revset completion matched" = { fg = "#dbbc7f", bold = true }
      "revset completion dimmed" = { fg = "#859289" }
      "revset completion selected" = { bg = "#475258", fg = "#d3c6aa" }

      # "revisions" = { fg = "#d3c6aa" }
      "revisions selected" = { bg = "#343f44"}
      "revisions dimmed" = { fg = "#859289" }
      "revisions details selected" = { bg = "#475258" }
      "oplog selected" = { bold = true }

      "evolog" = { fg = "#d3c6aa" }
      "evolog selected" = { bg = "#475258", fg = "#d3c6aa", bold = true }

      "menu" = { bg = "#2d353b" }
      "menu title" = { fg = "#2d353b", bg = "#d699b6", bold = true }
      "menu shortcut" = { fg = "#d699b6" }
      "menu matched" = { fg = "#dbbc7f", bold = true }
      "menu dimmed" = { fg = "#859289" }
      "menu border" = { fg = "#343f44"  }
      "menu selected" = { bg = "#475258", fg = "#d3c6aa" }

      "help" = { bg = "#2d353b" }
      "help title" = { fg = "#a7c080", bold = true, underline = true }
      "help border" = { fg = "#343f44" }

      "preview" = { fg = "#d3c6aa" }
      "preview border" = { fg = "#343f44" }

      "confirmation" = { bg = "#2d353b" }
      "confirmation text" = { fg = "#7fbbb3", bold = true }
      "confirmation dimmed" = { fg = "#859289" }
      "confirmation border" = { fg = "#e67e80", bold = true }
      "confirmation selected" = { bg = "#475258", fg = "#d3c6aa" }

      "undo" = { bg = "#2d353b" }
      "undo confirmation dimmed" = { fg = "#859289" }
      "undo confirmation selected" = { bg = "#475258", fg = "#d3c6aa" }

      "success" = { fg = "#a7c080", bold = true }
      "error" = { fg = "#e67e80", bold = true }
      "revisions rebase source_marker" = { bold = true }
      "revisions rebase target_marker" = { bold = true }
      "status shortcut" = { fg = "#d699b6" }
      "status dimmed" = { fg = "#859289" }

      # "details" = { fg = "#d3c6aa" }
      "details selected" = { bold = true }
      "completion" = { fg = "#d3c6aa" }
      "completion selected" = { bold = true }
      "rebase" = { bold = true }

      "workspace" = { fg = "#7fbbb3" }
      "branch" = { fg = "#e69875" }
      "commit" = { fg = "#a7c080" }
      "file" = { fg = "#dbbc7f" }
      "change" = { fg = "#e67e80" }
      "bookmark" = { fg = "#d699b6" }
    '';
  };
}
