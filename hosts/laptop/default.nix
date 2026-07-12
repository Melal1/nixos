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
    ../../modules/nixos/hardware/gpu/nvidia.nix
    ../../modules/nixos/hardware/gpu/intel.nix
  ];

  networking.hostName = "zeta"; 


}
