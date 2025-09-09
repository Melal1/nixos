{
  programs.yazi.enable = true;
  xdg.configFile."yazi" = {
    source = ./config/yazi;
    recursive = true;
  };

}
