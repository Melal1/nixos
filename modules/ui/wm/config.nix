{ config, pkgs, lib, ... }:

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
    programs.hyprland.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      swww
      wl-clipboard
      rofi-wayland
      waybar
    ];
  };
}

