{ pkgs, config, ... }:
{

  environment.systemPackages = [
    pkgs.pulseaudio # for pactl
  ];

  services.zerotierone = {
    # enable = (config.networking.hostName == "alpha");
    enable = false;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };


  services.printing.enable = false;
  
  programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
}
