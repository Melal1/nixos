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
  options.my.home.dev.text.enable = lib.mkEnableOption "the Harper writing checker";

  config = lib.mkIf config.my.home.dev.text.enable {
    home.packages = fromSystem [ pkgs.harper ];
  };
}
