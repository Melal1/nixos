{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      gnome-frog
      st
      neovide
      protonvpn-gui
      filezilla
      puddletag
      papirus-icon-theme
      apple-cursor
      bibata-cursors
      unoconv
      kdePackages.dolphin
      localsend
      firefox
      # todoist-electron
      vlc
      mpv
      gdbgui
      # obsidian
      vscode
      zoom-us
      xournalpp
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
      ])
    else
      [ ]);

  programs.kdeconnect.enable = true;
  programs.steam = {
    enable = config.networking.hostName == "alpha";
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.obs-studio = {
    enable = config.networking.hostName == "alpha";

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-vkcapture
    ];
  };
}

