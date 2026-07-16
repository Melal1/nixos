{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;
  host = config.networking.hostName;

  blocksH = pkgs.writeText "blocks.h" (
    if host == "alpha" then ''
      #define BLOCKS(X) \
        X("  ", "file:/dev/shm/prayer_status", 1, 3)\
        X("", "awk '/MemTotal/ {t=$2} /MemFree|Buffers|Cached|SReclaimable/ {f+=$2} /Shmem/ {f-=$2} END {printf \"  %.2fG\", (t-f)/1048576}' /proc/meminfo", 1, 2) \
        X("", "date +'%a %d %b %H:%M'", 60, 1) \
    '' else if host == "zeta" then ''
      #define BLOCKS(X) \
        X("", "awk '/MemTotal/ {t=$2} /MemFree|Buffers|Cached|SReclaimable/ {f+=$2} /Shmem/ {f-=$2} END {printf \"   %.2fG \", (t-f)/1048576}' /proc/meminfo", 1, 2) \
        X("󰁹 ", "acpi -b | awk -F', ' '{print $2}'", 60, 3) \
        X("", "date +'%a %d %b %H:%M'", 60, 1)
    '' else ''
      #define BLOCKS(X) \
        X("", "date +'%a %d %b %H:%M'", 60, 1)
    ''
  );

in
{
  config = lib.mkIf (cfg.type == "dwm") {

    services.xserver = {
      displayManager.lightdm.enable = false;

      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm; # custom build from pkgs/dwm (via overlay)
      };
    };

    environment.etc =
      let host = config.networking.hostName;
      in lib.mkMerge [
        (lib.mkIf (host == "alpha") {
          "X11/xorg.conf.d/20-amdgpu.conf".text = ''
            Section "Device"
              Identifier "AMD Graphics"
              Driver "amdgpu"
              Option "TearFree" "true"
            EndSection
          '';

          "X11/xorg.conf.d/10-monitors.conf".text = ''
            Section "Monitor"
              Identifier "DisplayPort-0"
              Option "PreferredMode" "2560x1440_180"
              Option "RightOf" "HDMI-A-0"
              Modeline "2560x1440_180" 706.00 2560 2568 2600 2670 1440 1443 1448 1470 +hsync -vsync
              Option "Primary" "true"
            EndSection

            Section "Monitor"
              Identifier "HDMI-A-0"
              Option "LeftOf" "DisplayPort-0"
              Modeline "1920x1080_75" 174.50 1920 1968 2000 2080 1080 1083 1088 1119 +hsync -vsync
              Option "PreferredMode" "1920x1080_75"
            EndSection
          '';
        })

        (lib.mkIf (host == "zeta") {
          "X11/xorg.conf.d/10-monitor.conf".text = ''
            Section "Monitor"
              Identifier "eDP-1"
              Option "PreferredMode" "1920x1080_60"
              Option "Primary" "true"
            EndSection
          '';
        })
      ];

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      (dwmblocks-async.override { inherit blocksH; })
      xwinwrap
      pamixer
      feh
      xcolor
      picom
      dunst
      flameshot
    ];
  };
}
