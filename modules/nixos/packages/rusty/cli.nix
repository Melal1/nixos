{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Shared C/C++ shell packages are installed through development.nix.
    btop
    smassh
    brightnessctl
    codex
  ];
}
