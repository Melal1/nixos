{
  pkgs,
  unstable,
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
      obsidian
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
    ]);
}
