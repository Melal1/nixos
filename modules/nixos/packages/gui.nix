{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.gui.shared.enable {
    environment.systemPackages =
      (with pkgs; [
        libnotify
        xdg-user-dirs
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
        obsidian
        winetricks
        wineWow64Packages.stable
        xournalpp
        kdePackages.gwenview
        discord
        librewolf
      ])
      ++ (with unstable; [
        # vicinae
        localsend
        qpwgraph
        telegram-desktop
      ])
      ++ lib.optional config.my.virtualisation.databaseEnabled pkgs.pgmodeler;
  };
}
