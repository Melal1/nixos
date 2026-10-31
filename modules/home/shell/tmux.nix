{ config, lib, ... }:
{
  home.file.".config/tmux/tmux.conf" = lib.mkIf config.my.home.scripts.enable {
    source = ../programs/config/tmux.conf;
  };
}
