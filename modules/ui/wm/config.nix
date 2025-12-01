{ config, pkgs, lib, unstable, ... }:

let
  cfg = config.desktop;
in
{
  options.desktop.type = lib.mkOption {
    type = lib.types.enum [ "none" "hyprland" ];
    default = "none";
  };

  config = lib.mkIf (cfg.type == "hyprland") {
    programs.hyprland.enable = true;
    programs.hyprland.package = unstable.hyprland;
    programs.hyprland.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      rofi-wayland
      waybar
      swaynotificationcenter
    ];
  };
}

