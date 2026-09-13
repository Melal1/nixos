{ windowManager, ... }:
{
  imports = [
    ./terminals
    ./wm
    ./bars/waybar
    ./spicetify.nix
    ./git.nix
    ./fastfetch.nix
    ./mpd.nix
    ./yazi
    ./ncmpcpp
    ./lazygit
    ./nh.nix
    ./openrgb.nix
  ]
  # WM-specific programs, selected at import time via the windowManager specialArg.
  ++ (if windowManager == "hyprland" then [ ./swaync ]
  else if windowManager == "dwm" then [ ./picom.nix ]
  else [ ]);

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
