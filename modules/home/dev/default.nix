{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
{
  options.my.home.development.enable = lib.mkOption {
    type = lib.types.bool;
    default = osConfig != null && (osConfig.my.packages.development.shared.enable or false);
    description = "Editor configuration and debugger paths; follows the system's shared development tools by default.";
  };

  imports = [
    ./editorconfig.nix
  ];

  config = lib.mkIf config.my.home.development.enable {
    home.sessionVariables.CODELLDB_PATH = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };
}
