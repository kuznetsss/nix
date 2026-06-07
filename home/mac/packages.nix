{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # bitwarden-cli
    syncthing

    cmake
    ninja

    cargo-generate
    cargo-binutils
    rustup
    lldb

    deploy-rs

    typst
    tinymist
    typstyle
  ];
}
