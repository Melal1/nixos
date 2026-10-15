{ pkgs, ... }:
let
  packages = import ../../../../shells/package-groups.nix { inherit pkgs; };
in
{
  environment.systemPackages = packages.cpp;
  # Retain outputs such as headers even when they have no links in the system profile.
  system.extraDependencies = map (package: package.outPath) packages.cpp;
}
