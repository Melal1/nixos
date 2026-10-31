{
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../../modules/home/lib/after-home-packages.nix lib;
  sys = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = fromSystem (
    (with pkgs; [
      # Development and electronics
      # Personal Android client, available independently of the host webcam bundle.
      android-tools
      arduino-ide
      jetbrains.rider
      logisim-evolution

      # System monitoring
      btop-rocm

      # Communication
      element-desktop
      discord
      iamb

      # Media and graphics
      imagemagick
      puddletag

      # Documents and statistics
      libreoffice
      pspp

      # Gaming
      prismlauncher
    ])
    ++ (with unstable; [
      # Development assistants
      codex
      opencode

      # Networking and remote access
      cloudflared
      anydesk

      # Media
      vlc
      # Keep the former shared CLI priority so Noctalia's stable FFmpeg wins.
      ffmpeg
    ])
    ++ [
      # Terminal communication
      inputs.tincan-cli.packages.${sys}.default

      # Typing practice
      inputs.toofan.packages.${sys}.default
    ]
  );
}
