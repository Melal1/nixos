{
  config,
  lib,
  hostname,
  ...
}:

lib.mkIf config.my.home.wm.dwm.enable {
  home.file.".xprofile".text = ''
    #!/usr/bin/env bash

    pkill -x xwinwrap 2>/dev/null
    pkill -f 'mpv .* -wid ' 2>/dev/null
    pkill .vicinae-wrappe 2>/dev/null
    pkill dwmblocks 2>/dev/null
    pkill prayer

    vicinae server &
    dwmblocks &
    prayer -b &
  ''
  + (
    if hostname == "snowflake" then
      ''
        xwinwrap -g 2560x1440+1920+0 -ni -un -st -sp -b -nf -ov \
          -- mpv --cache=no --vo=gpu --hwdec=vaapi --loop --mute=yes \
          --stop-screensaver=no -wid WID ~/Videos/Wallpapers/rain2k.webm &

        xwinwrap -g 1920x1080+0+0 -ni -un -st -sp -b -nf -ov \
          -- mpv --cache=no --vo=gpu --hwdec=vaapi --loop --mute=yes \
          --stop-screensaver=no -wid WID ~/Videos/Wallpapers/rainFhd.webm &
      ''
    else
      ''
        # xwinwrap -g 1920x1080+0+0 -ni -un -st -sp -b -nf -ov \
          #   -- mpv --cache=no --vo=gpu --loop --mute=yes \
          #   --stop-screensaver=no -wid WID ~/Videos/Wallpapers/rainFhd.webm &
        feh --bg-scale ~/Pictures/Wallpapers/black.jpg
      ''
  )
  + ''
    picom &

    xset r 200 30 &
  '';
}
