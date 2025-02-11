{ pkgs, ... }: {
  home.packages = with pkgs; [
    llvmPackages_19.clang-tools
    lldb
    gcovr
    cmake-language-server
    cmake
    cmake-format
    ninja
    ccache
    git-lfs
    git-cliff
    k6
    typescript-language-server

    netcat-gnu

    python313Full
    python313Packages.virtualenv
    # python311Packages.python-lsp-server
    # python311Packages.black
    # python311Packages.flake8
    # python311Packages.mccabe
    # python311Packages.pylsp-rope
    # python311Packages.python-lsp-black
    # python311Packages.matplotlib

    jq
    tree
    yazi

    rustup

    websocat
  ];
}
