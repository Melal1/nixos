{ lib, ... }:
{
  imports = [
    ./cache.nix
    ./fonts.nix
    ./optimization.nix
  ];
  options.my.packages.fonts.shared.enable = lib.mkEnableOption "the shared system font collection";
}
