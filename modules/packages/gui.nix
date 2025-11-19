{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      kitty
      gnome-frog
      protonvpn-gui
      filezilla
      puddletag
      waybar
      wlogout
      papirus-icon-theme
      hyprpicker
      discord
      vesktop
      apple-cursor
      bibata-cursors
      unoconv
      kdePackages.dolphin
      firefox
      nwg-displays
      obs-studio
      todoist-electron
      vlc
      mpv
      gdbgui
      obsidian
      vscode
    ])
    ++
    (with unstable; [
      nmgui
    ])
    ++
    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        wineWowPackages.stable
        winetricks
      ])
    else
      [ ]);

  programs.kdeconnect.enable = true;
}

