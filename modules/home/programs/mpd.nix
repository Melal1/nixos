{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.home.media.enable = lib.mkEnableOption "the MPD, ncmpcpp and playerctld media setup";

  config = lib.mkIf config.my.home.media.enable {
    # Media owns its commands and notification integration, independently of
    # the system CLI/GUI package lists or the selected window manager.
    home.packages = with pkgs; [
      mpc
      playerctl
      libnotify
      mpd-mpris
    ];
    programs.ncmpcpp.enable = true;
    services.playerctld.enable = true;
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
  };
}
