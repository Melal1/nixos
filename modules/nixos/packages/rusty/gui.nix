{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nmgui
  ];
}
