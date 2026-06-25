{ pkgs, unstable, config, lib, ... }:
{
  options.my.services = {
    ollama.enable = lib.mkEnableOption "Ollama service";
    extraGraphics.enable = lib.mkEnableOption "Extra graphics groups for user";
  };


  config = {

    services.ollama = {
      enable = config.my.services.ollama.enable;
      package = unstable.ollama-rocm;

      rocmOverrideGfx = "10.3.0";
    };

    users.users.melal.extraGroups = lib.mkIf config.my.services.extraGraphics.enable [
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


    services.sunshine = {
      enable = true;
      autoStart = false;
      # capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
      openFirewall = true;
      settings = {
        file_apps = "/home/melal/.config/sunshine/custom_apps.json";
      };
    };

    hardware.uinput.enable = true;

    services.printing.enable = false;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
