{ windowManager,... }:
{
  imports = ([
    ./git.nix
    ./fastfetch.nix
    ./mpd.nix
    ./yazi
    ./ncmpcpp
    ./lazygit
  ])
  ++ (if windowManager == "hyprland" then [ ./swaync ]
  else if windowManager == "dwm" then [ ./picom.nix ]
  else [ ]);
  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
