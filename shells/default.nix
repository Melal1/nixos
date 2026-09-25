{ pkgs }:
{
  ncurses = import ./ncurses.nix { inherit pkgs; };
  dpp = import ./dpp.nix { inherit pkgs; };
  fmt = import ./fmt.nix { inherit pkgs; };
  qksh = import ./quickshell.nix { inherit pkgs; };
  nodejs22 = import ./npm.nix { inherit pkgs; };
  javafx = import ./javafx.nix { inherit pkgs; };
  py = import ./python.nix { inherit pkgs; };
  avalonia = import ./avalonia.nix { inherit pkgs; };
}
