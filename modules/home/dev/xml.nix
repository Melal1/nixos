{
  config,
  lib,
  pkgs,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.xml.enable = lib.mkEnableOption "XML tooling";

  config = lib.mkIf config.my.home.dev.xml.enable {
    home.packages = fromSystem [ pkgs.libxml2 ];
  };
}
