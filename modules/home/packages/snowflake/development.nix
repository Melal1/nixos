{
  lib,
  pkgs,
  ...
}:
let
  fromSystem = import ../../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    with pkgs;
    [
      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      prettier
      eslint
    ]
  );
}
