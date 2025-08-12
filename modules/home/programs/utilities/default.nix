{
  imports = [
  ./git.nix
  ./fetch.nix
  ];

  home.file.".config/tmux/tmux.conf" = {
    source = ./config/tmux.conf;
  };
}
