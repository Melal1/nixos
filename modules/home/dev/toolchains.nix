{
  config,
  lib,
  pkgs,
  ...
}:
let
  groups = import ../../../shells/package-groups.nix { inherit pkgs; };
  cfg = config.my.home.development.toolchains;
  selected = builtins.filter (name: cfg.${name}.enable) groups.names;
  fromSystem = import ../lib/after-home-packages.nix lib;
  packages = fromSystem (groups.packagesFor selected);
in
{
  options.my.home.development.toolchains = lib.genAttrs groups.names (name: {
    enable = lib.mkEnableOption "globally installing the ${name} development environment's packages";
  });

  config = lib.mkIf config.my.home.development.enable {
    home.packages = packages;
    # Keep headers and other selected outputs alive through home generations.
    home.extraDependencies = map (package: package.outPath) packages;
  };
}
