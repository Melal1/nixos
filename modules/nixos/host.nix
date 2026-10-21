{ config, lib, ... }:
let
  cfg = config.my.host;
in
{
  options.my.host = {
    displays = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Wayland display output names available on this host.";
    };

    hasBattery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host has a battery.";
    };

  };

  config.assertions = [
    {
      assertion = !config.my.hardware.batteryOpt.enable || cfg.hasBattery;
      message = "my.hardware.batteryOpt.enable requires my.host.hasBattery = true.";
    }

  ];
}
