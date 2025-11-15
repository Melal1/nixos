{
  imports = [
    ./hardware/configuration.nix
    ../../users
    ./structure.nix
    # ./kernel.nix
    ./keyboard.nix
  ];
  networking.hostName = "alpha";
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

}
