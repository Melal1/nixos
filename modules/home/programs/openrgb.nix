{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  rgbEnabled =
    if osConfig != null && (osConfig ? my.hardware.rgb.enable) then
      osConfig.my.hardware.rgb.enable
    else
      false;
in
{
  options.my.home.openrgb = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = rgbEnabled;
      description = "Autostart OpenRGB client minimized to tray";
    };
  };

  config = lib.mkIf config.my.home.openrgb.enable {
    systemd.user.services.openrgb-client = {
      Unit = {
        Description = "OpenRGB Client (minimized)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect --startminimized";
        Restart = "on-failure";
        RestartSec = "3";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
