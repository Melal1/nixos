{ config, lib, ... }:
{
  my.home.dev = {
    cpp = {
      enable = lib.mkDefault true;
      dpp.enable = lib.mkDefault config.my.home.dev.cpp.enable;
      fmt.enable = lib.mkDefault config.my.home.dev.cpp.enable;
      ncurses.enable = lib.mkDefault config.my.home.dev.cpp.enable;
      qksh.enable = lib.mkDefault config.my.home.dev.cpp.enable;
    };
    csharp.enable = lib.mkDefault true;
    java.enable = lib.mkDefault true;
    python.enable = lib.mkDefault true;
    lua.enable = lib.mkDefault true;
    nix.enable = lib.mkDefault true;
    shell.enable = lib.mkDefault true;
    json.enable = lib.mkDefault true;
    xml.enable = lib.mkDefault true;
    text.enable = lib.mkDefault true;
  };
}
