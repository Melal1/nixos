{ pkgs }:

pkgs.mkShell {
  packages = [ pkgs.fmt pkgs.gcc pkgs.gnumake ];

  shellHook = ''
      # Only switch to fish if we are not already in fish
    if [ -t 1 ] && [ -z "$FISH" ] && command -v fish >/dev/null 2>&1; then
      exec fish --login
  '';
}


