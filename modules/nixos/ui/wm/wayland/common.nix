{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop;
in
{
  config = lib.mkIf (cfg.type == "niri" || cfg.type == "hyprland") {

    environment.systemPackages = with pkgs; [
      wl-clipboard
      nwg-displays
      gnome-frog
      awww
    ];

  };
}

