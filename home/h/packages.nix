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
    lldb_19

    deploy-rs
  ];
}
