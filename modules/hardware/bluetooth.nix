{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = [
    pkgs.bluetui
  ];
}
