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
  cpp = import ./cpp.nix { inherit pkgs; };
  audio = import ./audio.nix { inherit pkgs; };
  py-science = import ./python-science.nix { inherit pkgs; };
  dotnet = import ./dotnet.nix { inherit pkgs; };
  rust = pkgs.mkShell {
    packages = with pkgs; [
      cargo
      rustc
      rustfmt
      clippy
    ];
  };
  go = pkgs.mkShell {
    packages = [ pkgs.go ];
  };
  lua = pkgs.mkShell {
    packages = with pkgs; [
      lua
      luajit
    ];
  };
}
