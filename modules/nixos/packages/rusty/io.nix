{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    acpi
    iw
    linux-wifi-hotspot
  ];
}
