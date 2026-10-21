{
  config,
  lib,
  pkgs,
  ...
}:
let
  groups = import ../../../../shells/package-groups.nix { inherit pkgs; };
  cfg = config.my.development.toolchains;
  selected = builtins.filter (name: cfg.${name}.enable) groups.names;
  packages = groups.packagesFor selected;
in
{
  options.my.development.toolchains = lib.genAttrs groups.names (name: {
    enable = lib.mkEnableOption "globally installing the ${name} development environment's packages";
  });

  config = lib.mkIf config.my.packages.development.host.enable {
    environment.systemPackages = packages;
    # Keep headers and other selected outputs alive through system generations.
    system.extraDependencies = map (package: package.outPath) packages;
  };
}
