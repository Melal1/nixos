{ lib, pkgs, ... }:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem [ pkgs.docker-compose ];
}
