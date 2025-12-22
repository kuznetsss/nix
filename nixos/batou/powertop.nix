{ nixpkgs, ... }: {
  environment.systemPackages = with nixpkgs; [ powertop ];
  systemd.services.powertop-autotune = {
    type = "oneshot";
    script = "${nixpkgs.powertop}/bin/powertop --auto-tune";
    wantedBy = [ "multi-user.target" "sleep.target" ];
    unitConfig = { RemainAfterExit = true; };
  };
}
