{
  programs.git = {
    enable = true;
    userName = "melal";
    userEmail = "example@example.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
