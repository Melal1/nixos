{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
    pkgs.pkg-config
  ];

  buildInputs = [ pkgs.fmt ];
}
