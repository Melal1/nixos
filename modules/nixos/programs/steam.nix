{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.steam;

  steamWithGamingRuntime = pkgs.steam.override {
    extraPkgs =
      pkgs: with pkgs; [
        libxcursor
        libxi
        libxinerama
        libxscrnsaver
        stdenv.cc.cc.lib
        gamemode
        gperftools
        keyutils
        libkrb5
        libpng
        libpulseaudio
        libvorbis
        mangohud
      ];
  };
in
{
  options.my.programs.steam = {
    enable = lib.mkEnableOption "Steam gaming client";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.steamcmd
      pkgs.mangohud
    ];
    programs = {
      gamemode.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        package = steamWithGamingRuntime;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        protontricks.enable = true;
      };
    };
  };
}
