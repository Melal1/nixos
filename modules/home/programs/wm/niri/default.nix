{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  osConfig ? null,
  ...
}:
let
  cfg = config.my.home;
  fromSystem = import ../../../lib/after-home-packages.nix lib;
  niriDir = "${cfg.dotfilesDir}/modules/home/programs/wm/niri";
  hasBacklight = osConfig != null && (osConfig.my.host.hasBattery or false);
in
{
  config = lib.mkIf cfg.wm.niri.enable {
    assertions = [
      {
        assertion = osConfig == null || (osConfig.programs.niri.enable or false);
        message = "Niri user configuration requires the NixOS Niri session and PAM/portal prerequisites.";
      }
    ];
    home.packages = fromSystem (
      with pkgs;
      [
        inputs.qmlgolsp.packages.${stdenv.hostPlatform.system}.default
        inputs.quickshell-niri.packages.${stdenv.hostPlatform.system}.quickshell
        wl-clipboard
        nwg-displays
        gnome-frog
        cliphist
        swaylock
        orca
        procps
        wireplumber
      ]
      ++ lib.optional hasBacklight pkgs.brightnessctl
    );

    home.file.".config/niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/session.kdl";

    # Niri spawn does not expand shell variables; spawn-sh expands BROWSER.
    xdg.configFile."niri/browser.kdl".text =
      lib.optionalString (config.home.sessionVariables ? BROWSER)
        ''
          environment {
            BROWSER ${builtins.toJSON config.home.sessionVariables.BROWSER}
          }
          binds {
            Mod+B hotkey-overlay-title="Open browser" { spawn-sh "$BROWSER"; }
            Mod+Shift+B hotkey-overlay-title="Open browser" { spawn-sh "$BROWSER"; }
          }
        '';
    xdg.configFile."niri/applications.kdl".text = ''
      binds {
        ${lib.optionalString config.programs.foot.enable ''Mod+Q hotkey-overlay-title="Open foot" { spawn "foot"; }''}
        ${lib.optionalString config.programs.kitty.enable ''Mod+Shift+Q hotkey-overlay-title="Open kitty" { spawn "kitty"; }''}
        ${lib.optionalString cfg.skwd.enable ''Mod+Shift+W hotkey-overlay-title="Wallpaper Picker" { spawn "skwd-helm" "ui" "toggle"; }''}
        Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
        Super+Alt+S allow-when-locked=true hotkey-overlay-title=null { spawn-sh "pkill -u $(id -u) -x orca || exec orca"; }
        ${lib.optionalString cfg.media.enable ''
          XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
          XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
          XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
          XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
        ''}
        ${lib.optionalString hasBacklight ''
          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
        ''}
      }
    '';
    xdg.configFile."niri/noctalia.kdl" = lib.mkIf cfg.noctalia.enable {
      source = ../../noctalia/niri.kdl;
    };
    xdg.configFile."niri/themes/default.kdl".source = ./themes/default.kdl;
    home.activation.niriTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      dest=${lib.escapeShellArg "${config.xdg.configHome}/niri/default.kdl"}
      if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
        run ln -s ${lib.escapeShellArg "${config.xdg.configHome}/niri/themes/default.kdl"} "$dest"
      fi
    '';

    home.file.".local/bin/niri-autostart" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        export PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.procps
          ]
        }:$PATH
      ''
      + lib.optionalString cfg.skwd.enable ''
        WALL="$HOME/.local/state/theme/media"
        [ -e "$WALL" ] || WALL="$HOME/.local/state/theme/wallpaper"
        [ -e "$WALL" ] && ${
          inputs.skwd-wall.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/bin/skwd-helm apply "$WALL" &
      ''
      + lib.optionalString (cfg.gpu-screen-recorder.enable && cfg.gpu-screen-recorder.autostart) ''
        if ! pgrep -u "$UID" -x gsr-ui > /dev/null; then
          ${unstable.gpu-screen-recorder-ui}/bin/gsr-ui &
        fi
      '';
    };
  };
}
