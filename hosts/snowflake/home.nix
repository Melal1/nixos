{ ... }: {
  imports = [ ../../modules/home ];

  my.home = {
    desktop.enable = true;
    media.enable = true;
    noctalia.plugins = {
      discord-voice = {
        enable = true;
        widgets.bar = {
          capsule_border_width = 0.0;
          capsule_fill = "primary";
          glyph = "brand-discord-filled";
          hide_when_disconnected = true;
          scale = 1.1;
          show_channel_name = true;
        };
      };
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
      };
    };
  };

  # Home Manager owns these per-user applications and their configuration.
  programs = {
    git.enable = true;
    fastfetch.enable = true;
    yazi.enable = true;
    lazygit.enable = true;
    nh.enable = true;
    starship.enable = true;
  };

  home.sessionVariables.BROWSER = "helium";
}
