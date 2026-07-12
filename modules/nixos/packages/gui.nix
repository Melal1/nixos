{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      proton-vpn
      papirus-icon-theme
      apple-cursor
      bibata-cursors
      unoconv
      qbittorrent
      sioyek
      mpv
      gdbgui
      xournalpp
      element-desktop
      vscode
      firefox
      kdePackages.dolphin
      kdePackages.okular
      kdePackages.gwenview
    ])
    ++
    (with unstable; [
      kitty
      vicinae
      localsend
      discord
      brave
      antigravity
      telegram-desktop
    ])
    ++
    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        nmgui
      ])
    else if config.networking.hostName == "alpha" then
      (with pkgs; [
        prismlauncher
        logisim-evolution
        puddletag
      ])
      ++
      (with unstable; [
        (vesktop.overrideAttrs (finalAttrs: previousAttrs: {
          desktopItems = [
            ((builtins.elemAt previousAttrs.desktopItems 0).override {
              exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandFractionalScaleV1 %U";
            })
          ];
        }))
        vlc
        neovide
        qpwgraph
        anydesk
        opencode-desktop
      ])
    else
      [ ]);

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
