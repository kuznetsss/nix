{ ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [ ./zsh.nix ];
  home-manager.users.sergey =
    { ... }:
    {
      home.stateVersion = "26.05";
    };
}
