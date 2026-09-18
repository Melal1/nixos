{ ... }:
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
    ./swaync
    ./picom.nix
  ];

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
