{ config, lib, ... }:
{
  options.my.hardware.disablePcieWakeup.enable =
    lib.mkEnableOption "disabling wake events from PCIe port bridges";

  config = lib.mkIf config.my.hardware.disablePcieWakeup.enable {
    # Disables PCIe bridge wake events; devices behind these ports may no longer
    # wake the system. Enable only on hosts that need this suspend workaround.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
    '';
  };
}
