{
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
      prismlauncher
      logisim-evolution
      element-desktop
      puddletag
      libreoffice
      pspp

      jetbrains.rider

    ])
    ++ (with unstable; [
      vlc
      anydesk
      opencode
    ])
  );
}
