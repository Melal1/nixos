{ lib, ... }:

{
  imports = [
    ./wayland/niri.nix
  ];

  options.my.desktop = {
    niri.enable = lib.mkEnableOption "Niri Wayland scrollable-tiling compositor";
  };
}
