{ pkgs }:

let
  # Define the python environment once so we can reference it
  myPython = pkgs.python3.withPackages (p: [
    p.requests
    p.soundfile
    p.numpy
    p.matplotlib
    p.opencv-python
  ]);
in
pkgs.mkShell {
  packages = [
    myPython
  ];

  shellHook = ''
      # Only switch to fish if we are not already in fish
      export PYTHONPATH="${myPython}/${pkgs.python3.sitePackages}"
    if [ -t 1 ] && [ -z "$FISH" ] && command -v fish >/dev/null 2>&1; then
      exec fish --login
  '';
}


