{ lib, ... }:

{
  imports = [
    ./x11/dwm.nix
    ./x11/common.nix
    ./wayland/common.nix
    ./wayland/niri.nix
    ./wayland/hyprland.nix
  ];

  options.my.desktop = {
    niri.enable = lib.mkEnableOption "Niri Wayland scrollable-tiling compositor";
    hyprland.enable = lib.mkEnableOption "Hyprland Wayland compositor";
    dwm.enable = lib.mkEnableOption "dwm X11 dynamic window manager";
  };
}
