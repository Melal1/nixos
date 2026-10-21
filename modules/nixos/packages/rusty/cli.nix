{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.cli.host.enable {
    environment.systemPackages = with pkgs; [
      # Shared C/C++ shell packages are installed through development.nix.
      btop
      smassh
      brightnessctl
      codex
    ];
  };
}
