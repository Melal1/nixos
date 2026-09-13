{ pkgs, lib, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [
      proton-vpn
      kdePackages.krfb
      kdePackages.libkscreen # Provides kscreen-doctor for Plasma 6
      papirus-icon-theme
      font-manager
      apple-cursor
      bibata-cursors
      unoconv
      qbittorrent
      jetbrains.rider
      sioyek
      mpv
      gdbgui
      obsidian
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
      ghostty
      vicinae
      localsend
      discord
      # brave
      qpwgraph
      brave-origin
      telegram-desktop
      (vesktop.overrideAttrs (finalAttrs: previousAttrs: {
        desktopItems = [
          ((builtins.elemAt previousAttrs.desktopItems 0).override {
            exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandFractionalScaleV1 %U";
          })
        ];
      }))
    ])
    ++
    (if config.networking.hostName == "rusty" then
      (with pkgs; [
        nmgui
      ])
    else if config.networking.hostName == "snowflake" then
      (with pkgs; [
        prismlauncher
        logisim-evolution
        puddletag
      ])
      ++
      (with unstable; [
        vlc
        neovide
        anydesk
        opencode-desktop
      ])
    else
      [ ]);

  programs.steam = {
    enable = config.networking.hostName == "snowflake";

    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.obs-studio = {
    enable = config.networking.hostName == "snowflake" || config.networking.hostName == "rusty";

    plugins = lib.optionals (config.networking.hostName == "snowflake") (with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-vkcapture
    ]);
  };
}
