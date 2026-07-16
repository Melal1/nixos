{ config, lib, pkgs, ... }:
{
  options.my.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf config.my.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true; # Show battery charge of Bluetooth devices
        };
      };
    };
    services.blueman.enable = true;

    environment.systemPackages = [
      pkgs.bluetui
    ];
  };
}
