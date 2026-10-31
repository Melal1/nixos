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
      # Desktop files and appearance
      xdg-user-dirs
      nautilus
      papirus-icon-theme
      font-manager
      bibata-cursors

      # Networking and downloads
      proton-vpn
      qbittorrent

      # Documents and notes
      unoconv
      sioyek
      obsidian
      xournalpp

      # Media playback and images
      mpv
      kdePackages.gwenview

      # Windows compatibility
      wineWow64Packages.stable
      winetricks

      # Web browsing
      librewolf
    ])
    ++ (with unstable; [
      # Communication and file sharing
      localsend
      telegram-desktop

      # Audio routing
      qpwgraph
    ])
    ++ [
      # Web browsing
      inputs.helium-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
  );
}
