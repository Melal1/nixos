{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ./kernel.nix
  ];

  networking.hostName = "rusty";

  my.virtualisation.mssql.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    gpu.nvidia.enable = true;
    gpu.intel.enable = true;
    touchpad.enable = true;
    battery = {
      present = true;
      optimization.enable = true;
    };
    vial-qmk.enable = true;
  };

  my.desktop = {
    niri.enable = true;
  };

  my.packages.fonts.shared.enable = true;

  my.programs = {
    nix-ld.enable = true;

  };

  environment.systemPackages = with pkgs; [
    acpi
    iw
    linux-wifi-hotspot
  ];
}
