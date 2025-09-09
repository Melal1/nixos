{config,...}:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Audio";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';
  };
}

