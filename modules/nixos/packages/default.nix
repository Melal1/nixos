{
  hostname ? null,
  lib,
  ...
}:
let
  hostPackagesDir = ./. + "/${hostname}";
  hasHostDir = hostname != null && builtins.pathExists hostPackagesDir;
  hostModules =
    if hasHostDir then
      let
        files = builtins.readDir hostPackagesDir;
        nixFiles = lib.filterAttrs (
          name: type: (type == "regular" || type == "symlink") && lib.hasSuffix ".nix" name
        ) files;
      in
      map (f: hostPackagesDir + "/${f}") (builtins.attrNames nixFiles)
    else
      [ ];
in
{
  imports = [
    ./cache.nix
    ./io.nix
    ./cli.nix
    ./gui.nix
    ./dev/lsp.nix
    ./dev/languages.nix
    ./dev/libs.nix
    ./fonts.nix
  ]
  ++ hostModules;
}
