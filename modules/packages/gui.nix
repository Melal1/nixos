{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      normcap
      protonvpn-gui
      papirus-icon-theme
      apple-cursor
      bibata-cursors
      unoconv
      spotify
      # todoist-electron
      sioyek
      mpv
      gdbgui
      # obsidian
      localsend
      xournalpp
      vscode
    ])
    ++
    (with unstable; [
      discord
      kitty
      vicinae
    ])
    ++
    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        vscode
        kdePackages.dolphin
        brave
        nmgui
      ])
    else if config.networking.hostName == "alpha" then

      (with pkgs; [
        prismlauncher
        firefox
        logisim-evolution
        puddletag
      ])
      ++
      (with unstable;[
        vesktop
        vlc
        localsend
        neovide
        brave
        qpwgraph
        kdePackages.dolphin
        anydesk
        kdePackages.okular
        opencode-desktop
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

