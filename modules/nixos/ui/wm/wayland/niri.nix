{ config, lib, pkgs, qmlgolsp, quickshell-niri, ... }:

let
  cfg = config.desktop;
  hostname = config.networking.hostName;
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

      # ----------------------------------------------------
      # Zeta Configuration (Laptop / Single Monitor)
      # ----------------------------------------------------
      mpvpaper = lib.mkIf (hostname == "zeta") {
        description = "mpvpaper wallpaper with auto-restart (Zeta)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -v -o 'no-audio loop --hwdec=auto' eDP-1 %h/Videos/Wall/rainFhd.webm";
          Restart = "always";
          RestartSec = "2";
          RuntimeMaxSec = "1800";
        };
      };

      # ----------------------------------------------------
      # Alpha Configuration (Desktop / Dual Monitor)
      # ----------------------------------------------------
      mpvpaper-dp1 = lib.mkIf (hostname == "alpha") {
        description = "mpvpaper wallpaper DP-1 (Alpha)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -vs -o 'no-audio loop --vo=gpu --hwdec=vaapi' DP-1 %h/Videos/Wall/rain2k.webm";
          Restart = "always";
          RestartSec = "2";
          RuntimeMaxSec = "1800";
        };
      };

      mpvpaper-hdmi = lib.mkIf (hostname == "alpha") {
        description = "mpvpaper wallpaper HDMI-A-1 (Alpha)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -vs -o 'no-audio loop --vo=gpu --hwdec=vaapi' HDMI-A-1 %h/Videos/Wall/rainFhd.webm";
          Restart = "always";
          RestartSec = "2";
          RuntimeMaxSec = "1800";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      qmlgolsp.packages.${pkgs.stdenv.hostPlatform.system}.default
      quickshell-niri.quickshell
      xwayland-satellite
      nautilus
      mpd-mpris
      cliphist
      waybar
      mpvpaper
    ];
  };
}
