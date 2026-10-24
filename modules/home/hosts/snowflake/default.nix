{
  config,
  ...
}:
{
  imports = [
    ../noctalia.nix
    ../../packages/cli.nix
    ../../packages/gui.nix
    ../../packages/io.nix
    ../../packages/database-clients.nix
    ../../packages/snowflake/cli.nix
    ../../packages/snowflake/gui.nix
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
    };
  };

  my.home.dev = {
    cpp = {
      enable = true;
      audio.enable = true;
      dpp.enable = true;
      fmt.enable = true;
      ncurses.enable = true;
      qksh.enable = true;
    };
    csharp = {
      enable = true;
      avalonia.enable = true;
    };
    java.enable = true;
    python = {
      enable = true;
      science.enable = true;
    };
    lua.enable = true;
    javascript.enable = true;
    go.enable = true;
    rust.enable = true;
    nix.enable = true;
    shell.enable = true;
    json.enable = true;
    xml.enable = true;
    text.enable = true;
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
