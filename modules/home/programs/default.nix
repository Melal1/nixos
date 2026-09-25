{ ... }:
{
  imports = [
    ./terminals
    ./wm
    ./git.nix
    ./fastfetch.nix
    ./mpd.nix
    ./yazi
    ./ncmpcpp
    ./lazygit
    ./nh.nix
    ./openrgb.nix
  ];

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
