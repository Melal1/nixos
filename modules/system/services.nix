{ pkgs, unstable, ... }:
{

  environment.systemPackages = [
    pkgs.pulseaudio # for pactl
  ];

  services.zerotierone = {
    enable = false;
    package = unstable.zerotierone;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };


  services.printing.enable = false;
}
