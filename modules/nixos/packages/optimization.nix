{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.packages.optimization.arch = lib.mkOption {
    type = lib.types.strMatching "[A-Za-z0-9_+-]+";
    default = pkgs.stdenv.hostPlatform.gcc.arch or "x86-64";
    example = "znver3";
    description = "Default CPU architecture for packages selected with pkgs.optimizeForArch.";
  };

  config.nixpkgs.overlays = lib.mkAfter [
    (import ../../../overlays/host-arch.nix config.my.packages.optimization.arch)
  ];
}
