{
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../../modules/home/lib/after-home-packages.nix lib;
in
{
  programs.neovim = {
    enable = lib.mkDefault true;
    withRuby = lib.mkDefault false;
    withPython3 = lib.mkDefault true;
    sideloadInitLua = true; # The user's Neovim checkout owns ~/.config/nvim/init.lua.
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

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
