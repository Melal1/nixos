{ lib, pkgs }:
names:
let
  groups = import ../../../shells/package-groups.nix { inherit pkgs; };
  fromSystem = import ../lib/after-home-packages.nix lib;
  packages = fromSystem (groups.packagesFor names);
in
{
  home.packages = packages;
  # Root only outputs extracted from project shells, including library headers.
  home.extraDependencies = map (package: package.outPath) packages;
}
