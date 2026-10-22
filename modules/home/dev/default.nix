{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.home.development.enable =
    lib.mkEnableOption "editor configuration, debugger paths and selected global toolchains";

  imports = [
    ./editorconfig.nix
    ./toolchains.nix
  ];

  config = lib.mkIf config.my.home.development.enable {
    home.sessionVariables.CODELLDB_PATH = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };
}
