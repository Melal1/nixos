{ config, lib, ... }:
{
  imports = [
    ../noctalia.nix
    ../../packages/cli.nix
    ../../packages/gui.nix
    ../../packages/io.nix
    ../../packages/database-clients.nix
    ../../packages/rusty/cli.nix
    ../../packages/rusty/gui.nix
  ];

  my.home.noctalia = {
    configFile = lib.mkDefault "${config.my.home.dotfilesDir}/modules/home/hosts/rusty/noctalia-config.toml";
    plugins.discord-voice.enable = false;
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
    csharp.enable = true;
    java.enable = true;
    python.enable = true;
    lua.enable = true;
    nix.enable = true;
    shell.enable = true;
    json.enable = true;
    xml.enable = true;
    text.enable = true;
  };

}
