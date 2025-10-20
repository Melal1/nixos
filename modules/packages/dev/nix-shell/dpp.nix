{ pkgs }:

pkgs.mkShell {
  packages = [ pkgs.dpp pkgs.gcc pkgs.gnumake pkgs.cmake ];

  shellHook = ''
    if command -v fish >/dev/null 2>&1; then
        exec fish --login
    fi
  '';
}

