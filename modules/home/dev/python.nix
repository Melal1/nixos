{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.dev.python;
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.python = {
    enable = lib.mkEnableOption "Python, uv and Python editor tools";
    science.enable = lib.mkEnableOption "Python with the scientific package bundle";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        pyright
        ruff
        mypy
      ]
    );
  };
}
