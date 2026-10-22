{
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    (with pkgs; [
      btop-rocm
      imagemagick
      iamb
    ])
    ++ (with unstable; [
      codex
      cloudflared
    ])
    ++ [
      inputs.tincan-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
  );
}
