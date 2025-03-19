{
  #boot.loader.systemd-boot.enable = true ;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      #useOSProber = true ; 
    };
  };
}
