{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  cfg = config.my.home;
  fromSystem = import ../../../lib/after-home-packages.nix lib;
  niriDir = "${cfg.dotfilesDir}/modules/home/programs/wm/niri";
  hasBattery = osConfig != null && (osConfig.my.hardware.battery.present or false);
in
{
  options.my.home.wm.niri.startupCommands = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Shell commands contributed by applications to run from the Niri startup script.";
  };

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
        wl-clipboard
        nwg-displays
        gnome-frog
        cliphist
        # orca
        # procps
        wireplumber
      ]
      ++ lib.optional hasBattery pkgs.brightnessctl
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
        ${lib.optionalString cfg.media.enable ''
          XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
          XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
          XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
          XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
        ''}
        ${lib.optionalString hasBattery ''
          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
        ''}
      }
    '';
    xdg.configFile."niri/noctalia.kdl" = lib.mkIf cfg.noctalia.enable {
      source = ../../noctalia/niri.kdl;
    };

    # this looks bit confusing , what it does is :
    # it make a niri/themes/default.kdl symlink to the file on the store ( unmutable ) , then after that it checks does
    # niri/default.kdl exist ? if yes then do nothing if no then link it to the unmutable link so it act as default .

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
      + cfg.wm.niri.startupCommands;
    };
  };
}
