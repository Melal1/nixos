{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf (cfg.type == "dwm") {
    services.xserver = {
      displayManager.lightdm.enable = false;

      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm.overrideAttrs (_: {
          src = ../../../home/programs/wm/dwm;
        });
      };
    };

    environment.systemPackages = with pkgs; [
      dmenu
    ];
  };
}

