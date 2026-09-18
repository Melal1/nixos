{ config, ... }:
{
  boot = {
    kernelParams = [
      "mitigations=off"
      "quiet"
    ];

    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        useOSProber = config.networking.hostName == "snowflake";
      };
    };
  };
}
