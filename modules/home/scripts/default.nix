{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.my.home.scripts.disableHyprlandEffects =
    lib.mkEnableOption "Disable Hyprland effects script";

  config = {
    home.sessionPath = [ "$HOME/.local/bin" ];

    home.file = lib.mkMerge [

      {
        ".local/bin/assets-setup" = {
          source = "${
            import ./assets-setup.nix {
              inherit pkgs;
              dotfilesDir = config.my.home.dotfilesDir;
            }
          }/bin/assets-setup";
          executable = true;
        };
        ".local/bin/theme-switch" = {
          source = "${import ./theme-switch.nix { inherit pkgs; }}/bin/theme-switch";
          executable = true;
        };
        ".local/bin/tmux-sessionizer" = {
          source = ./tmux/tmux-sessionizer;
          executable = true;
        };
        ".config/tmux-sessionizer/tmux-sessionizer.conf" = {
          source = ./tmux/tmux-se.conf;
        };
        ".local/bin/bright" = {
          source = ./brightness.sh;
          executable = true;
        };
        ".local/bin/audio" = {
          source = ./audio.sh;
          executable = true;
        };
        ".local/bin/gengitcommit" = {
          source = ./gitcommit.sh;
          executable = true;
        };
        ".local/bin/SCRIPT_MP3d" = {
          source = ./SCRIPT-MP3D.sh;
          executable = true;
        };
        ".local/bin/open-github-tmux" = {
          source = ./open-github-tmux.sh;
          executable = true;
        };
        ".local/bin/cir.sh" = {
          source = ./cir.sh;
          executable = true;
        };
        ".local/bin/pomodoro" = {
          source = ./pomodoro.fish;
          executable = true;
        };
      }

      (lib.mkIf (config.my.home.scripts.disableHyprlandEffects && config.my.home.wm.hyprland.enable) {
        ".local/bin/DisableHyprlandEffects" = {
          source = ./DisableHyprlandEffects.sh;
          executable = true;
        };
      })

      (lib.mkIf config.my.home.wm.hyprland.enable {
        ".local/bin/wlogout-script" = {
          source = ./wlogout.sh;
          executable = true;
        };
        ".local/bin/wallSet.py" = {
          source = ./wall.py;
          executable = true;
        };
      })
      (lib.mkIf (pkgs ? gh) {
        ".local/bin/vicinaegithub.sh" = {
          source = ./vicinae-github.sh;
          executable = true;
        };
      })
    ];
  };
}
