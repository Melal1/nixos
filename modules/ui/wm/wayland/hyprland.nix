{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf (cfg.type == "hyprland") {
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      rofi
      wlogout
      hyprpicker
      nwg-displays
      waybar
      hyprshot
      swaynotificationcenter
    ];
  };
}
