{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.my.desktop;
  hostname = config.networking.hostName;
  sys = pkgs.stdenv.hostPlatform.system;
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
      nautilus
      mpd-mpris
      cliphist
    ];
  };
}
