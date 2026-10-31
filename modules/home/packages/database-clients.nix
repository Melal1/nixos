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
    # Database clients
    unstable.lazysql
    pkgs.sqlcmd

    # Schema design
    pkgs.pgmodeler
  ];
}
