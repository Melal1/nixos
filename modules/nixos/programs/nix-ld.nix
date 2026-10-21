{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.nix-ld.enable =
    lib.mkEnableOption "runtime compatibility for externally built Linux binaries";

  config = lib.mkIf config.my.programs.nix-ld.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libx11
        qt6.qtbase
        stdenv.cc.cc.lib
        libglvnd
        icu
        zlib
      ];
    };
  };
}
