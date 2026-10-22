{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:

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
      unstable.xwayland-satellite
      xdg-desktop-portal-gtk
      nautilus
    ];
  };
}
