{ config, ... }:
{
  boot =
    {
      kernelParams = [
        "mitigations=off"
        "quiet"
      ];

      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = (
            if config.networking.hostName == "alpha" then
              true
            else
              false
          );
        };
      };
    };
}
