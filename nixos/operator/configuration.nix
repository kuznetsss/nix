{ pkgs, private, ... }:
import ../common/core_server.nix {
  inherit pkgs private;
  hostName = "operator";
}
