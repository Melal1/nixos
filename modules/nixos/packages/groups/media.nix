{ pkgs, unstable, config, lib, ... }: {
  config = lib.mkIf config.my.groups.media.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs obs-backgroundremoval obs-pipewire-audio-capture
        obs-vaapi obs-vkcapture
      ];
    };
    environment.systemPackages = (with pkgs; [
      spotify mpv easyeffects cava
      kdePackages.gwenview
    ]) ++ (with unstable; [
      vlc qpwgraph yt-dlp ffmpeg
     telegram-desktop
      rar
      zip
    ]);
  };
}
