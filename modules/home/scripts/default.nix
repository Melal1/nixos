{ hostname, lib, ... }:
{
  # Add local/bin to PATH
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
      ".local/bin/kittSwitch" = {
        source = ./switcher.sh;
        executable = true;
      };
      ".local/bin/wallSet" = {
        source = ./wallSet;
        executable = true;
      };
      ".local/bin/gengitcommit" = {
        source = ./gitcommit.sh;
        executable = true;
      };
      ".local/bin/wlogout-script" = {
        source = ./wlogout.sh;
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

    }

    (lib.mkIf (hostname == "zeta") {
      ".local/bin/DisableHyprlandEffects" = {
        source = ./DisableHyprlandEffects.sh;
        executable = true;
      };
    })
  ];
}

