{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.desktop.dwm.enable {

    services = {
      displayManager.ly.enable = true;

      xserver = {
        enable = true;

        xkb = {
          layout = "us,ara";
          options = "grp:alt_space_toggle,caps:escape";
        };

        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
      };
    };

    environment.systemPackages = with pkgs; [
      xrandr
      xsetroot
      normcap
      xclip
    ];

  };
}
