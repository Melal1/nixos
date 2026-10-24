{ config, lib, ... }:
let
  cfg = config.my.hardware.battery;
in
{
  options.my.hardware.battery = {
    present = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host has a battery.";
    };
    optimization.enable = lib.mkEnableOption "battery optimisation (power-profiles-daemon, deep sleep)";
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.optimization.enable || cfg.present;
          message = "my.hardware.battery.optimization.enable requires my.hardware.battery.present = true.";
        }
      ];
    }
    (lib.mkIf cfg.optimization.enable {
      services.auto-cpufreq.enable = false;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
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
    })
  ];
}
