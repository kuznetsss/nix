{ pkgs, ... }: {
  home.packages = with pkgs; [
    clang-tools_16
    cmake-language-server
    cmake
    ninja
    lldb
    ccache

    python311Packages.python-lsp-server
    gh
    jq

    gnupg
  ];
}
