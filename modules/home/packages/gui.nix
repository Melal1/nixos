{
  inputs,
  pkgs,
  unstable,
  lib,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
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
      localsend
      qpwgraph
      telegram-desktop
    ])
    ++ [ inputs.helium-flake.packages.${pkgs.stdenv.hostPlatform.system}.default ]
  );
}
