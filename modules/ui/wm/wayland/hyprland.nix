{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    rofi
    wlogout
    hyprpicker
    nwg-displays
    waybar
    swaynotificationcenter
  ];
}
