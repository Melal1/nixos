{

  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
    ./kitty.nix
    ./git.nix
    ./fish.nix
  ];



  home.stateVersion = "24.11";
}
