{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.my.desktop.hyprland.enable {
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      rofi
      wlogout
      hyprpicker
      grim
      waybar
      hyprshot
      swaynotificationcenter
    ];
  };
}
