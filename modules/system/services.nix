{ pkgs, unstable, config, lib, ... }:
{
  services.ollama = {
    enable = (config.networking.hostName == "alpha");
    package = unstable.ollama-rocm;

    rocmOverrideGfx = "10.3.0";
  };

  users.users.melal.extraGroups = lib.mkIf (config.networking.hostName == "alpha") [
    "video"
    "render"
  ];

  environment.systemPackages = [
    pkgs.pulseaudio # for pactl
  ];


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


