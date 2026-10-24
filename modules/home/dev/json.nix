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
  options.my.home.dev.json.enable = lib.mkEnableOption "the JSON language server";

  config = lib.mkIf config.my.home.dev.json.enable {
    # Share the JavaScript module's bundle to avoid conflicting JSON server binaries.
    home.packages = fromSystem [ pkgs.vscode-langservers-extracted ];
  };
}
