{ config, lib, ... }:
lib.mkIf config.my.home.wm.dwm.enable {
  services.picom = {
    enable = true;

    backend = "glx";

    vSync = true;

    settings = {
      inactive-opacity = 1.0;
      blur = {
        method = "dual_kawase";
        strength = 7;
      };
    };
  };
}
