{

  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
    ./programs/terminals/kitty.nix
    ./git.nix
    ./shell
    ./programs/bars/waybar.nix
  ];



  home.stateVersion = "24.11";
}
