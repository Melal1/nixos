{ config, lib, ... }:
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
    ./hardware-clients.nix
    ./gpu-screen-recorder.nix
    ./easyeffects.nix
    ./obs.nix
    ./skwd.nix
    ./noctalia
  ];

  home.file.".config/tmux/tmux.conf" = lib.mkIf config.my.home.scripts.enable {
    source = ./config/tmux.conf;
  };
}
