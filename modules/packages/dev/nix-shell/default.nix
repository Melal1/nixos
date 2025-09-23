{ pkgs }:
{
  ncurses = import ./ncurses.nix { inherit pkgs; };
}
