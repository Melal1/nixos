{ config, lib, pkgs, ... }:
{
  options.my.hardware.rgb.enable = lib.mkEnableOption "OpenRgb Support";

  config = lib.mkIf config.my.hardware.rgb.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      server.port = 6742;
    };
  };
}

