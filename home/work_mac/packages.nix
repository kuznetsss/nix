{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    ansible
    ansible-lint
    yaml-language-server
    _1password-cli
    claude-code
    claude-code-acp
    sshfs
    fuse

    conan
    llvmPackages_20.clang-tools
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

    python3
    python3Packages.virtualenv
    prek

    jq
    tree
    yazi

    rustup

    websocat
  ];
}
