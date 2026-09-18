{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    smassh
    brightnessctl
    codex
  ];
}
