{ config, lib, pkgs, qmlgolsp, quickshell-niri, ... }:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf (cfg.type == "niri") {
    programs.niri.enable = true;
    services = {
      displayManager.ly.enable = true;

    };


    qt.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      config = {
        common.default = [ "gnome" ];
      };
    };


    environment.systemPackages = with pkgs; [
      qmlgolsp.packages.${pkgs.stdenv.hostPlatform.system}.default
      quickshell-niri.quickshell
      xwayland-satellite
      nautilus # it's already installed with gnome protal so why not expose it
      waybar
      mpvpaper # memory leak 
    ];
  };
}
