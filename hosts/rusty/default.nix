{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ./kernel.nix
  ];

  networking.hostName = "rusty";

  my.packages.optimization.arch = "tigerlake";
  my.packages.fonts.shared.enable = true;

  programs.dconf.enable = true;

  my.virtualisation = {
    podman.enable = true;
    mssql.enable = true;
  };

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

  my.desktop.niri.enable = true;
  my.programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    acpi
    iw
    linux-wifi-hotspot
  ];
}
