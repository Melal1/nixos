{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ./kernel.nix
  ];

  networking.hostName = "rusty";

  my.host = {
    displays = [ "eDP-1" ];
    hasBattery = true;
  };

  my.virtualisation.mssql.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    gpu.nvidia.enable = true;
    gpu.intel.enable = true;
    touchpad.enable = true;
    batteryOpt.enable = true;
    vial-qmk.enable = true;
  };

  my.desktop = {
    niri.enable = true;
  };

  my.packages.fonts.shared.enable = true;

  my.programs = {
    nix-ld.enable = true;

  };

  # Host diagnostics and network administration remain available system-wide.
  environment.systemPackages = with pkgs; [
    acpi
    iw
    linux-wifi-hotspot
  ];
}
