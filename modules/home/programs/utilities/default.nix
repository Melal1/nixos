{
  imports = [
    ./git.nix
    ./fetch.nix
    ./mpd.nix
    ./yazi.nix
    # ./vicinae.nix
  ];

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
