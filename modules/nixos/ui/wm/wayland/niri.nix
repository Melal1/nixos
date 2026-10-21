{
  config,
  lib,
  pkgs,
  inputs,
  unstable,
  ...
}:

let
  sys = pkgs.stdenv.hostPlatform.system;
in
{
  config = lib.mkIf config.my.desktop.niri.enable {
    programs.niri.enable = true;
    services = {
      displayManager.ly.enable = true;
    };

    qt.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal
        xdg-desktop-portal-gtk
        # xdg-desktop-portal-gnome
      ];
      config = {
        # common.default = [ "gnome" ];
        common.default = [ "gtk" ];
      };
    };

    environment.systemPackages = with pkgs; [
      inputs.qmlgolsp.packages.${sys}.default
      inputs.quickshell-niri.packages.${sys}.quickshell
      unstable.xwayland-satellite
      xdg-desktop-portal-gtk
      nautilus
      cliphist
    ];
  };
}
