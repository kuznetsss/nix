{ nixpkgs }:
let
  lib = nixpkgs.lib;
in
rec {
  system = {
    aarch64-darwin = "aarch64-darwin";
    x86_64-linux = "x86_64-linux";
  };

  forEachSystem = func:
    lib.genAttrs (lib.attrValues system)
      (system: func system);

  readFileOpt = filepath:
    if builtins.pathExists filepath && builtins.readFileType == "regular" then
      builtins.readFile filepath
    else
      builtins.trace "No such file: ${filepath}" "";
}
