{
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../../modules/home/lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    (with pkgs; [
      # System monitoring, device controls and networking
      btop
      brightnessctl
      nmgui

      # Development
      # Personal Android client, available independently of the host webcam bundle.
      android-tools
      codex
      jetbrains.rider

      # Communication
      discord

      # Typing practice
      smassh
    ])
    # Media tools
    # Keep the former shared CLI priority so Noctalia's stable FFmpeg wins.
    ++ [ unstable.ffmpeg ]
  );
}
