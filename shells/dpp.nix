{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.dpp
    pkgs.opusfile
    pkgs.liboggz
    pkgs.fmt
  ];
}
