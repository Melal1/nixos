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
  # Import option declarations on every host; each list gates its own contents.
  options.my.packages = lib.genAttrs [ "cli" "gui" "io" "development" "fonts" ] (group: {
    shared.enable = lib.mkEnableOption "the shared ${group} package list";
    host.enable = lib.mkEnableOption "this host's ${group} package list";
  });

  imports = [
    ./cache.nix
    ./io.nix
    ./cli.nix
    ./gui.nix
    ./dev/lsp.nix
    ./fonts.nix
  ]
  ++ hostModules;
}
