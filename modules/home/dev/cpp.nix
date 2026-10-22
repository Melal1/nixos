{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.dev.cpp;
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.cpp = {
    enable = lib.mkEnableOption "the C++ toolchain and editor tools";
    audio.enable = lib.mkEnableOption "the C++ audio libraries and their build dependencies";
    dpp.enable = lib.mkEnableOption "DPP and its C++ build dependencies";
    fmt.enable = lib.mkEnableOption "fmt and its C++ build dependencies";
    ncurses.enable = lib.mkEnableOption "ncurses and its C++ build dependencies";
    qksh.enable = lib.mkEnableOption "Quickshell and its Qt build dependencies";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        vscode-extensions.ms-vscode.cpptools
        bear
        cmake-language-server
      ]
    );
    home.sessionVariables.CODELLDB_PATH = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };
}
