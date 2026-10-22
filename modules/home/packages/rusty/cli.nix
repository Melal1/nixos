{ lib, pkgs, ... }:
let
  fromSystem = import ../../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    with pkgs;
    [
      btop
      smassh
      brightnessctl
      codex
    ]
  );
}
