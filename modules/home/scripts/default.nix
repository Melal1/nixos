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
  home.file.".local/bin/bright" = {
    source = ./brightness.sh;
    executable = true;
  };
  home.file.".local/bin/audio" = {
    source = ./audio.sh;
    executable = true;
  };
  home.file.".local/bin/kittSwitch" = {
    source = ./switcher.sh;
    executable = true;
  };
  home.file.".local/bin/wallSet" = {
    source = ./wallSet;
    executable = true;
  };
  home.file.".local/bin/gengitcommit" = {
    source = ./gitcommit.sh;
    executable = true ;
  };
    
}
