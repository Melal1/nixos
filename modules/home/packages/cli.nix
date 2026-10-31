{
  pkgs,
  unstable,
  lib,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    (with pkgs; [
      # Files and directories
      fd
      tree
      eza

      # Archives
      unzip

      # Data processing and shell utilities
      jq
      moreutils
      bc

      # Command reference
      tealdeer

      # Terminal text
      lolcat
      figlet
    ])
    ++ (with unstable; [
      # Archives
      zip
      rar

      # Media downloads
      yt-dlp

      # Agent management
      herdr
    ])
  );
}
