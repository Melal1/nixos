{
  config,
  ...
}:
{
  imports = [
    ../../packages/cli.nix
    ../../packages/gui.nix
    ../../packages/io.nix
    ../../packages/database-clients.nix
    ../../packages/development.nix
    ../../packages/snowflake/cli.nix
    ../../packages/snowflake/gui.nix
    ../../packages/snowflake/development.nix
  ];

  my.home = {
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
        widgets.widget.widget-glyph-main = "clock";
        widgets.widget.widget-glyph-work = "coffee";
      };
    };
  };

  my.home.development.toolchains = {
    audio.enable = true;
    avalonia.enable = true;
    cpp.enable = true;
    dotnet.enable = true;
    dpp.enable = true;
    fmt.enable = true;
    go.enable = true;
    lua.enable = true;
    ncurses.enable = true;
    nodejs22.enable = true;
    py.enable = true;
    py-science.enable = true;
    qksh.enable = true;
    rust.enable = true;
  };

  my.home.openrgb.enable = true;
  my.home.noctalia.enable = true;
  my.home.noctalia.configFile = "${config.my.home.dotfilesDir}/modules/home/hosts/snowflake/noctalia-config.toml";
  my.home.gpu-screen-recorder = {
    enable = true;
    autostart = true;
  };
  services.easyeffects.enable = true;
  programs.obs-studio.enable = true;
  my.home.obs.gstreamer.enable = true;

}
