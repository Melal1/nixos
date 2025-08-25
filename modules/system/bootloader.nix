{
  #boot.loader.systemd-boot.enable = true ;
  boot =
    {
      kernelParams = [
        "mitigations=off"
      ];

      loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true ; 
        };
      };
    };
}
