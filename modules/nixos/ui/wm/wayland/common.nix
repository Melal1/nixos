{
  config,
  lib,
  pkgs,
  ...
}:
let
  isWayland = config.my.desktop.niri.enable;
in
{
  config = lib.mkIf isWayland {
    services.skwd-deck.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      nwg-displays
      gnome-frog
    ];

  };
}
