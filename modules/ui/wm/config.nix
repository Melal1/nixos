{ lib, ... }:

{
  imports = [
    ./x11/dwm.nix
    ./x11/common.nix
    ./wayland/hyprland.nix
  ];

  options.desktop.type = lib.mkOption {
    type = lib.types.enum [ "none" "hyprland" "dwm" ];
    default = "none";
    description = "Select desktop environment / window manager";
  };
}

