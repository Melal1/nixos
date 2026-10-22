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
  options.my.home.dev.nix.enable = lib.mkEnableOption "Nix editor tools";

  config = lib.mkIf config.my.home.dev.nix.enable {
    home.packages = fromSystem (
      with pkgs;
      [
        nil
        nixpkgs-fmt
      ]
    );
  };
}
