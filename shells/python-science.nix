{ pkgs }:
pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (p: [
      p.requests
      p.soundfile
      p.numpy
      p.matplotlib
      p.opencv4Full
      p.pyqt6
    ]))
  ];
}
