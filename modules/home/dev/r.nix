{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.my.home.dev.r;
  fromSystem = import ../lib/after-home-packages.nix lib;
  # Keep R and its libraries aligned with RStudio's supported Electron build.
  rPkgs = with unstable.rPackages; [
    nortest
    ggplot2
    dplyr
  ];
in
{
  options.my.home.dev.r = {
    enable = lib.mkEnableOption "R with nortest, ggplot2 and dplyr";
    ide = lib.mkEnableOption "RStudio with the R package bundle";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem (
      [ (unstable.rWrapper.override { packages = rPkgs; }) ]
      ++ lib.optional cfg.ide (unstable.rstudioWrapper.override { packages = rPkgs; })
    );
  };
}
