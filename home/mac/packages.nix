{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # bitwarden-cli
    syncthing

    cargo-generate
    cargo-binutils
    rustup
    lldb

    typst
    tinymist
    typstyle
  ];
}
