{
  imports = [
    ./hardware/configuration.nix
    ./users/melal.nix
    ./structure.nix
    # ./kernel.nix
    ./keyboard.nix
  ];
  networking.hostName = "alpha";
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

}
