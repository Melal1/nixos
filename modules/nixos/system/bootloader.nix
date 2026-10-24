{
  boot = {
    kernelParams = [
      "quiet"
    ];

    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
      };
    };
  };
}
