{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  niriEnabled =
    if osConfig != null && (osConfig ? my.desktop.niri.enable) then
      osConfig.my.desktop.niri.enable
    else
      false;
  hyprlandEnabled =
    if osConfig != null && (osConfig ? my.desktop.hyprland.enable) then
      osConfig.my.desktop.hyprland.enable
    else
      false;
  dwmEnabled =
    if osConfig != null && (osConfig ? my.desktop.dwm.enable) then
      osConfig.my.desktop.dwm.enable
    else
      false;
in
{
  options.my.home.wm = {
    niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = niriEnabled;
      description = "Enable Niri window manager user configuration";
    };
    hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = hyprlandEnabled;
      description = "Enable Hyprland window manager user configuration";
    };
    dwm.enable = lib.mkOption {
      type = lib.types.bool;
      default = dwmEnabled;
      description = "Enable dwm window manager user configuration";
    };
  };

  imports = [
    ./hyprland
    ./dwm
    ./niri
  ];
}
