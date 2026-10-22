{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.dev.java;
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.java = {
    enable = lib.mkEnableOption "JDK 21 and the Java language server";
    javafx.enable = lib.mkEnableOption "the JavaFX SDK and its native dependencies";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        jdk21
        jdt-language-server
      ]
    );
  };
}
