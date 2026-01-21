{ hostname, windowManager, lib, ... }:

{
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file = lib.mkMerge [

    {
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
        source = ./open-github.sh;
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

     (lib.mkIf (hostname == "zeta" && windowManager == "hyprland") {
        ".local/bin/DisableHyprlandEffects" = {
          source = ./DisableHyprlandEffects.sh;
          executable = true;
        };
      })

     (lib.mkIf (windowManager == "hyprland") {
        ".local/bin/wlogout-script" = {
          source = ./wlogout.sh;
          executable = true;
        };
        ".local/bin/THEMS.sh" = {
          source = ./Themeswitcher.sh;
          executable = true;
        };
        ".local/bin/wallSet" = {
          source = ./wallSet;
          executable = true;
        };
        ".local/bin/wallSet.py" = {
          source = ./wall.py;
          executable = true;
        };
      })

     # (lib.mkIf (windowManager == "dwm") {
     #    ".local/bin/DWMAUTOSTART.sh" = {
     #      source = ./DWMAUTOSTART.sh;
     #      executable = true;
     #    };
     #  })
  ];
}

