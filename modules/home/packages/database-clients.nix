{
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem [
    unstable.lazysql
    pkgs.pgmodeler
  ];
}
