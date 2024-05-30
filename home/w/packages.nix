{ pkgs, ... }: {
  home.packages = with pkgs; [
    clang-tools_18
    lldb_18
    gcovr
    cmake-language-server
    cmake
    cmake-format
    ninja
    ccache
    doxygen
    git-lfs

    netcat-gnu

    # python312Full
    # python311Packages.python-lsp-server
    # python311Packages.black
    # python311Packages.flake8
    # python311Packages.mccabe
    # python311Packages.pylsp-rope
    # python311Packages.python-lsp-black
    # python311Packages.matplotlib

    jq
    tree

    websocat
  ];
}
