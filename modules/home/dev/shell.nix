{
  config,
  lib,
  pkgs,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.shell.enable = lib.mkEnableOption "shell editor and checking tools";

  config = lib.mkIf config.my.home.dev.shell.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        shellcheck
        shfmt
        bash-language-server
      ]
    );
  };
}
