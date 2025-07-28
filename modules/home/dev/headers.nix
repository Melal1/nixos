{ pkgs, ... }:

{
  home.sessionVariables = {
    CPLUS_INCLUDE_PATH = "${pkgs.ncurses.dev}/include";
    LIBRARY_PATH       = "${pkgs.ncurses.out}/lib";
  };
}

