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
  options.my.home.dev.rust.enable = lib.mkEnableOption "the Rust toolchain and language server";

  config = lib.mkIf config.my.home.dev.rust.enable {
    home.packages = fromSystem [ pkgs.rust-analyzer ];
  };
}
