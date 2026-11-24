{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.dev.cpp;
  fromSystem = import ../lib/after-home-packages.nix lib;
  cpptools = pkgs.vscode-extensions.ms-vscode.cpptools.overrideAttrs (oldAttrs: {
    src = oldAttrs.src.overrideAttrs (srcAttrs: {
      # Microsoft's GitHub asset has the same hash; Marketplace downloads reset.
      urls = [
        "https://github.com/microsoft/vscode-cpptools/releases/download/v1.31.5/cpptools-linux-x64.vsix"
      ]
      ++ (srcAttrs.urls or [ ]);
      curlOptsList = (srcAttrs.curlOptsList or [ ]) ++ [ "--http1.1" ];
    });
  });
in
{
  options.my.home.dev.cpp = {
    enable = lib.mkEnableOption "the C++ toolchain and editor tools";
    dpp.enable = lib.mkEnableOption "DPP and its C++ build dependencies";
    fmt.enable = lib.mkEnableOption "fmt and its C++ build dependencies";
    ncurses.enable = lib.mkEnableOption "ncurses and its C++ build dependencies";
    qksh.enable = lib.mkEnableOption "Quickshell and its Qt build dependencies";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        cpptools
        bear
        cmake-language-server
      ]
    );
    home.sessionVariables.CODELLDB_PATH = "${cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };
}
