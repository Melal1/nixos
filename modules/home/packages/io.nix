{
  pkgs,
  lib,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    with pkgs;
    [
      # Device file access
      jmtpfs

      # Audio controls
      alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
      pavucontrol
    ]
  );
}
