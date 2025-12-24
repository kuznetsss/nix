{ pkgs, ... }: {
  boot.kernelModules =
    [ "nct6775" ]; # Needs to access pwm devices on Asus motherboards
  environment.systemPackages = [ pkgs.lm_sensors ];
  hardware.fancontrol = {
    enable = false; # Let bios handle it for now
    config = ''
      INTERVAL=10
      DEVPATH=hwmon0=devices/pci0000:00/0000:00:06.0/0000:01:00.0/nvme/nvme0 hwmon1=devices/platform/nct6775.656
      DEVNAME=hwmon0=nvme hwmon1=nct6798
      FCTEMPS=hwmon1/pwm2=hwmon0/temp1_input
      FCFANS= hwmon1/pwm2=hwmon1/fan2_input
      MINTEMP=hwmon1/pwm2=45
      MAXTEMP=hwmon1/pwm2=70
      MINSTART=hwmon1/pwm2=255
      MINSTOP=hwmon1/pwm2=50
      MINPWM=hwmon1/pwm2=50
    '';
  };
}
