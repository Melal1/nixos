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
      musicDirectory = lib.mkDefault "${config.home.homeDirectory}/Audio";
      network.startWhenNeeded = true;
      network.listenAddress = "${config.services.mpd.dataDir}/socket";
      extraConfig = ''
              audio_output {
                type "pipewire"
                name "My PipeWire Output"
              }
              audio_output {
            type                    "fifo"
            name                    "my_fifo"
            path                    "${config.services.mpd.dataDir}/visualizer.fifo"
            format                  "44100:16:2"
        }
      '';
    };

    # Pinned HM adds TCP plus %t/mpd/socket. Keep socket activation, replacing
    # both listeners with the same private Unix socket used by MPD and clients.
    systemd.user.sockets.mpd.Socket = {
      ListenStream = lib.mkForce [ config.services.mpd.network.listenAddress ];
      SocketMode = "0600";
      DirectoryMode = "0700";
    };
  };
}
