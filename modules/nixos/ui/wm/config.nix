{ lib, ... }:

{
  imports = [
    ./x11/dwm.nix
    ./x11/common.nix
    ./wayland/common.nix
    ./wayland/niri.nix
    ./wayland/hyprland.nix
  ];

  options.my.desktop.type = lib.mkOption {
    type = lib.types.enum [ "none" "hyprland" "dwm" "niri" ];
    default = "none";
    description = "Select desktop environment / window manager";
  };
}

