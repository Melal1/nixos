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

    gpus = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "amd"
          "intel"
          "nvidia"
        ]
      );
      default = [ ];
      description = "GPU vendors present in this host.";
    };
  };

  config.assertions = [
    {
      assertion = !config.my.hardware.batteryOpt.enable || cfg.hasBattery;
      message = "my.hardware.batteryOpt.enable requires my.host.hasBattery = true.";
    }
    {
      assertion = !config.my.hardware.gpu.amd.enable || lib.elem "amd" cfg.gpus;
      message = "my.hardware.gpu.amd.enable requires \"amd\" in my.host.gpus.";
    }
    {
      assertion = !config.my.hardware.gpu.intel.enable || lib.elem "intel" cfg.gpus;
      message = "my.hardware.gpu.intel.enable requires \"intel\" in my.host.gpus.";
    }
    {
      assertion = !config.my.hardware.gpu.nvidia.enable || lib.elem "nvidia" cfg.gpus;
      message = "my.hardware.gpu.nvidia.enable requires \"nvidia\" in my.host.gpus.";
    }
  ];
}
