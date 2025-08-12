{

  # Add local/bin to path
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.file.".local/bin/tmux-sessionizer" = {
    source = ./tmux/tmux-sessionizer;
    executable = true;
  };
  home.file.".config/tmux-sessionizer/tmux-sessionizer.conf" = {
    source = ./tmux/tmux-se.conf;
  };
}
