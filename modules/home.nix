{

  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "melal";
    userEmail = "example@example.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };


  home.stateVersion = "24.11";
}
