{
  imports = [
    ./git.nix
    ./fetch.nix
    ./mpd.nix
    ./yazi.nix
  ];

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
