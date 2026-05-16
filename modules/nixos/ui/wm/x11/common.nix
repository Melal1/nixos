{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf (cfg.type == "dwm") {

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
      xorg.xrandr
      xorg.xsetroot
      xclip
    ];

  };
}

