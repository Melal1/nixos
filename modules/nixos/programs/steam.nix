{ config, lib, ... }:
let
  cfg = config.my.programs.steam;
in
{
  options.my.programs.steam = {
    enable = lib.mkEnableOption "Steam gaming client";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
