{
boot.loader.efi.canTouchEfiVariables = true ;
#boot.loader.systemd-boot.enable = true ;
boot.loader.grub = { enable = true; 
device = "nodev";
efiSupport = true ; 
#useOSProber = true ; 
};
}
