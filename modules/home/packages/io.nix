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
      jmtpfs
      alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
      android-tools
      pavucontrol
    ]
  );
}
