{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
  ];

  buildInputs = [ pkgs.ncurses ];
}
