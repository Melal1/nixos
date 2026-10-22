{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.zerotierone.enable = false;

  hardware.uinput.enable = true;

  services.printing.enable = false;

}
