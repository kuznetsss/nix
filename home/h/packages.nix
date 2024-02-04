{ pkgs, ... }: {
  home.packages = with pkgs; [
    bitwarden-cli
    syncthing

    cmake
    ninja
  ];
}
