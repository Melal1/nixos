{ pkgs, ... }:
{

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
}
