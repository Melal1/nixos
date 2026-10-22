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
  options.my.home.dev.javascript.enable =
    lib.mkEnableOption "the JavaScript/TypeScript runtime and web editor tools";

  config = lib.mkIf config.my.home.dev.javascript.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        watchman
        yarn
        typescript-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        prettier
        eslint
      ]
    );
  };
}
