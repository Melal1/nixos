{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Audio";
    network.startWhenNeeded = true;
    extraConfig = ''
    port  "6600"
            audio_output {
              type "pipewire"
              name "My PipeWire Output"
            }
            audio_output {
          type                    "fifo"
          name                    "my_fifo"
          path                    "/tmp/mpd.fifo"
          format                  "44100:16:2"
      }
    '';
  };
}

