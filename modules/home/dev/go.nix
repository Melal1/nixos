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
  options.my.home.dev.go.enable = lib.mkEnableOption "the Go toolchain and language server";

  config = lib.mkIf config.my.home.dev.go.enable {
    home.packages = fromSystem [ pkgs.gopls ];
  };
}
