{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  serverPort = if osConfig == null then 6742 else osConfig.services.hardware.openrgb.server.port;
in
{
  options.my.home.openrgb = {
    enable = lib.mkEnableOption "the OpenRGB tray client (requires a host OpenRGB server)";
  };

  config = lib.mkIf config.my.home.openrgb.enable {
    assertions = [
      {
        assertion = osConfig == null || osConfig.services.hardware.openrgb.enable;
        message = "The OpenRGB Home client requires services.hardware.openrgb.enable on its NixOS host.";
      }
    ];

    systemd.user.services.openrgb-client = {
      Unit = {
        Description = "OpenRGB Client (minimized)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:${toString serverPort} --nodetect --startminimized";
        Restart = "on-failure";
        RestartSec = "3";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
