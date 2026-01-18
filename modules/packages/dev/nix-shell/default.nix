{ pkgs }:
{
  ncurses = import ./ncurses.nix { inherit pkgs; };
  dpp = import ./dpp.nix { inherit pkgs; };
  fmt = import ./fmt.nix { inherit pkgs; };
  qksh = import ./quikshell.nix { inherit pkgs; };
}
