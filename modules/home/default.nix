{
  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
    ./programs/terminals
    ./shell
    ./programs/bars
    ./dev
    ./scripts
    ./programs/utilities
    ./programs/utilities
    ./programs/wm
    ../ui/gtk.nix
  ];



  home.stateVersion = "24.11";
}
