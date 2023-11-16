{ pkgs, ... }: {
  home.packages = with pkgs; [
    llvmPackages_14.libcxxClang
    clang-tools_16
    cmake-language-server
    cmake
    ninja
    lldb
    ccache

    python311Full
    python311Packages.python-lsp-server
    python311Packages.black
    python311Packages.flake8
    python311Packages.mccabe
    python311Packages.pylsp-rope
    python311Packages.python-lsp-black
    python311Packages.matplotlib

    gh
    jq

    gnupg
  ];
}
