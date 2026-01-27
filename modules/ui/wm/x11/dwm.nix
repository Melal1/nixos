{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf (cfg.type == "dwm") {

    services.xserver = {
      displayManager.lightdm.enable = false;

      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm.overrideAttrs (old: {
          src = ../../../home/programs/wm/dwm;
          buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.xorg.libX11
            pkgs.xorg.libXinerama
            pkgs.xorg.libXft
            pkgs.xorg.libxcb
            pkgs.fribidi
            pkgs.fontconfig
          ];
        });
      };

      extraConfig =
        if config.networking.hostName == "alpha" then
          ''
            Section "Device"
                    Identifier      "AMD Graphics"
                    Driver          "amdgpu"
                    Option          "TearFree" "true"
            EndSection

            Section "Monitor"
                Identifier   "DisplayPort-0"
                Option  "PreferredMode"  "2560x1440_180"
                Option  "RightOf" "HDMI-A-0"
                Modeline "2560x1440_180"  706.00  2560 2568 2600 2670  1440 1443 1448 1470 +hsync -vsync
                Option  "Primary" "true"
            EndSection

            Section "Monitor"
                Identifier   "HDMI-A-0"
                Option  "LeftOf" "DisplayPort-0"
                Modeline "1920x1080_75"  174.50  1920 1968 2000 2080  1080 1083 1088 1119 +hsync -vsync
                Option  "PreferredMode"  "1920x1080_75"
            EndSection
          '' else if config.networking.hostName == "zeta" then
          ''
            Section "Monitor"
                Identifier "eDP-1"
                Option "PreferredMode" "1920x1080_60"
                Option "Primary" "true"
            EndSection
          '' else
          ''
          '';



    };
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      (stdenv.mkDerivation {
        pname = "dwmblocks-async";
        version = "4.20.24";
        src = ../../../home/programs/wm/dwm/dwmblocks-async;

        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ xorg.libX11 fribidi ] ++ builtins.attrValues { inherit (xorg) libxcb xcbutil; };

        makeFlags = [ "PREFIX=$(out)" ];

        meta = {
          description = "Async dwmblocks";
          license = lib.licenses.bsd3;
        };
      })
      pamixer
      feh
      xcolor
      dunst
      flameshot
    ];
  };
}

