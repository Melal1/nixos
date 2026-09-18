{
  config,
  lib,
  pkgs,
  ...
}:
let
  isWayland = config.my.desktop.niri.enable || config.my.desktop.hyprland.enable;
in
{
  config = lib.mkIf isWayland {

    environment.systemPackages = with pkgs; [
      wl-clipboard
      nwg-displays
      gnome-frog
      awww
    ];

  };
}
