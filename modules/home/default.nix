{
  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
    ./programs/terminals
    ./shell
    ./dev
    ./scripts
    ./programs/utilities
    ./programs/wm
    ../ui/gtk.nix
    ./assests
  ];



  home.stateVersion = "24.11";
}
