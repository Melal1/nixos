{ lib, ... }:
{
  my.home.noctalia = {
    enable = lib.mkDefault true;
    plugins = lib.mkDefault {
      bongocat = {
        enable = true;
        widgets.cat = {
          capsule = false;
          capsule_opacity = 0.23000000000000001;
          color = "primary";
          font_scale = 1.3400000000000001;
          icon_color = "primary";
          input_devices = [
            "/dev/input/by-id/usb-foostan_Corne_v4_vial:f64c2b3c-event-kbd"
          ];
          interactive = false;
        };
      };
      nix-search.enable = true;
      timer.enable = true;
      pomodoro = {
        enable = true;
        settings = {
          auto-start-breaks = true;
          long-break-duration = 45;
          short-break-duration = 25;
          work-duration = 45;
        };
        widgets.widget.scale = 1.25;
        widgets.widget.widget-glyph-main = "clock";
        widgets.widget.widget-glyph-work = "coffee";
      };
    };
  };
}
