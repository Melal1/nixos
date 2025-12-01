{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      gnome-frog
      protonvpn-gui
      filezilla
      puddletag
      wlogout
      papirus-icon-theme
      hyprpicker
      apple-cursor
      bibata-cursors
      unoconv
      kdePackages.dolphin
      firefox
      nwg-displays
      obs-studio
      # todoist-electron
      vlc
      mpv
      gdbgui
      # obsidian
      # vscode
    ])
    ++
    (with unstable; [
      nmgui
      discord
      kitty
      vesktop
    ])
    ++
    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        wineWowPackages.stable
        winetricks
      ])
    else if config.networking.hostName == "alpha" then

      (with pkgs; [
        prismlauncher
        steam
      ])
    else
      [ ]);

  programs.kdeconnect.enable = true;
}

