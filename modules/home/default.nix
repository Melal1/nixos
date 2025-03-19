{

  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
  ./kitty.nix
  ./git.nix
  ];



  home.stateVersion = "24.11";
}
