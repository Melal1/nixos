{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      normcap
      protonvpn-gui
      papirus-icon-theme
      apple-cursor
      bibata-cursors
      unoconv
      kdePackages.dolphin
      localsend
      firefox
      brave
      # todoist-electron
      sioyek
      mpv
      gdbgui
      # obsidian
      xournalpp
      vscode
    ])
    ++
    (with unstable; [
      nmgui
      discord
      kitty
      vicinae
    ])
    ++
    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        vscode
      ])
    else if config.networking.hostName == "alpha" then

      (with pkgs; [
        prismlauncher
        logisim-evolution
        puddletag
        vlc
        neovide
        qpwgraph
        anydesk
      ])
      ++
      (with unstable;[
        vesktop
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

