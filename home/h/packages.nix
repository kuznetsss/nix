{ pkgs, ... }: {
  home.packages = with pkgs; [
    # bitwarden-cli
    syncthing

    cmake
    ninja
    git-agecrypt

    cargo-generate
    cargo-binutils
    rustup

    deploy-rs
  ];
}
