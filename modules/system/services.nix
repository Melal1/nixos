{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.pulseaudio # for pactl
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.printing.enable = false;
}
