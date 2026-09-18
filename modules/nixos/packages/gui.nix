{
  pkgs,
  lib,
  unstable,
  config,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
      proton-vpn
      papirus-icon-theme
      font-manager
      apple-cursor
      bibata-cursors
      unoconv
      qbittorrent
      jetbrains.rider
      sioyek
      mpv
      gdbgui
      obsidian
      xournalpp
      element-desktop
      firefox
      kdePackages.dolphin
      kdePackages.gwenview
      discord

    ])
    ++ (with unstable; [
      # vicinae
      localsend
      qpwgraph
      brave-origin
      telegram-desktop
    ]);
}
