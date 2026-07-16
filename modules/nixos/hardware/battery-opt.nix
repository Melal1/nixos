{ config, lib, ... }:
{
  options.my.hardware.batteryOpt.enable = lib.mkEnableOption "battery optimisation (auto-cpufreq, deep sleep)";

  config = lib.mkIf config.my.hardware.batteryOpt.enable {
    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
    boot.kernelParams = [ "mem_sleep_default=deep" ];
  };
}
