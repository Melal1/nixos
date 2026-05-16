{ pkgs, ... }:
{
  imports = [
    ./hardware/configuration.nix
    ../../users
    ../../modules/nixos/system
    ../../modules/nixos/hardware/input/touchpad.nix
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/ui
    ../../modules/nixos/packages
    ../../modules/nixos/hardware/battery-opt.nix
  ];

  networking.hostName = "zeta"; 

  my.groups = {
    desktop.enable = true;
    laptop.enable = true;
    network.enable = true;
    dev.enable = true;
  };
}
