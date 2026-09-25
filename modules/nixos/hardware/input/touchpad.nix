{ config, lib, ... }:
{
  options.my.hardware.touchpad.enable = lib.mkEnableOption "touchpad support (libinput)";

  config = lib.mkIf config.my.hardware.touchpad.enable {
    services.libinput.enable = true;
  };
}
