{ config, pkgs, ... }: {
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";

      # Enable SATA Aggressive Link Power Management
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      AHCI_RUNTIME_PM_TIMEOUT = 15;

      # Keep the CPU from boosting unnecessarily for background tasks
      CPU_BOOST_ON_AC = 0;
      # Force PCIe ASPM
      PCIE_ASPM_ON_AC = "powersave";
    };
  };
  powerManagement.powertop.enable = true;

  boot.postBootCommands = ''
    # --- REALTEK NIC & BRIDGE ---
    # Enable ASPM L1 (Value 42) on Bridge 00:1c.7 and NIC 04:00.0
    ${pkgs.pciutils}/bin/setpci -s 00:1c.7 50.b=42
    ${pkgs.pciutils}/bin/setpci -s 04:00.0 80.b=42

    # --- SAMSUNG SSD & BRIDGE ---
    # Enable ASPM L1 on Bridge 00:06.0 and SSD 01:00.0
    ${pkgs.pciutils}/bin/setpci -s 00:06.0 50.b=42
    ${pkgs.pciutils}/bin/setpci -s 01:00.0 80.b=42
  '';

  # Force Runtime PM for everything that Powertop might miss
  services.udev.extraRules = ''
    # Disable wake on lan
    ACTION=="add", SUBSYSTEM=="net", NAME=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol d"
  '';
  boot.kernelParams = [
    "pcie_aspm=force" # Force ASPM even if BIOS says no
    "i915.enable_fbc=1" # Enable Frame Buffer Compression (saves power on iGPU)
    "i915.enable_guc=3" # Use Graphics Microcode for power management
    "nvme_core.default_ps_max_latency_us=5500"
    "i915.enable_dc=2"
    "intel_idle.max_cstate=10" # Explicitly allow C10
    "vt.global_cursor_default=0" # Stop cursor wakeups
  ];
  environment.systemPackages = with pkgs; [ powertop pciutils powerstat];

  boot.kernelModules = [ "r8125" ];
  boot.blacklistedKernelModules =
    [ "r8169" ]; # Stop the default driver from loading
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];

  # Pass the 'aspm=1' flag to the r8125 driver to force power savings
  boot.extraModprobeConfig = ''
    options r8125 aspm=1
  '';
}
