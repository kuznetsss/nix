{ pkgs, lib, ... }:
{
  home.activation.report-changes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -n "''${oldGenPath:-}" && "$oldGenPath" != "$newGenPath" ]]; then
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath"
    fi
  '';
}
