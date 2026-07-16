{ pkgs }:

pkgs.mkShell {
  packages = [ pkgs.ncurses pkgs.gcc pkgs.gnumake ];

  shellHook = ''
    if command -v fish >/dev/null 2>&1; then
        exec fish --login
    fi
  '';
}

