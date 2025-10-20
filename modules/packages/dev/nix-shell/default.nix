{ pkgs }:
{
  ncurses = import ./ncurses.nix { inherit pkgs; };
  dpp = import ./dpp.nix { inherit pkgs; };
}
