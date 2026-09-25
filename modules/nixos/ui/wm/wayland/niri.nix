{
  config,
  lib,
  pkgs,
  inputs,
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

    systemd.user.services = {
      xwayland-satellite = {
        description = "Xwayland outside Wayland";
        bindsTo = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
          StandardOutput = "journal";
          Restart = "on-failure";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      inputs.qmlgolsp.packages.${sys}.default
      inputs.qml-niri.packages.${sys}.quickshell
      xwayland-satellite
      xdg-desktop-portal-gtk
      nautilus
      mpd-mpris
      cliphist
    ];
  };
}
