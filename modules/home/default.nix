{

  home.username = "melal";
  home.homeDirectory = "/home/melal/";
  programs.home-manager.enable = true;
  imports = [
    ./programs/terminals/kitty.nix
    ./shell
    ./programs/bars
    ./dev/headers.nix
    ./programs/utilities/git.nix
    ./programs/utilities/fetch.nix
  ];



  home.stateVersion = "24.11";
}
