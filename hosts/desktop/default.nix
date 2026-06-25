{ pkgs, unstable, ... }:
{
  imports = [
    ./hardware/configuration.nix
    ../../users
    ./keyboard.nix
    ../../modules/nixos/system
    ../../modules/nixos/ui
    ../../modules/nixos/packages
    ../../modules/nixos/hardware/gpu/amd.nix
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/hardware/performance.nix
  ];
  
  networking.hostName = "alpha";
  
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';



  my.services = {
    # ollama.enable = true;
    extraGraphics.enable = true;
  };
}
