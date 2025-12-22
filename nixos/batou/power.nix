{ pkgs, ... }: {
  powerManagement.powertop.enable = true;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  #
  #     # Enable SATA Aggressive Link Power Management
  #     SATA_LINKPWR_ON_AC = "med_power_with_dipm";
  #
  #     # Keep the CPU from boosting unnecessarily for background tasks
  #     CPU_BOOST_ON_AC = 0;
  #   };
  # };
  # boot.kernelParams = [
  #   "pcie_aspm=force" # Force ASPM even if BIOS says no
  #   "i915.enable_fbc=1" # Enable Frame Buffer Compression (saves power on iGPU)
  #   "i915.enable_guc=3" # Use Graphics Microcode for power management
  # ];
  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver # Required for modern QuickSync (i3-12100)
  #     intel-compute-runtime # Optional, for OpenCL tasks
  #   ];
  # };
  # systemd.tmpfiles.rules =
  #   [ "w /sys/module/pcie_aspm/parameters/policy - - - - powersave" ];
  # environment.systemPackages = [ pkgs.powertop ];
}
