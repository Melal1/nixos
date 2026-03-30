{ pkgs }:

pkgs.mkShell {
  packages = [ pkgs.jdk21 pkgs.openjfx ];
  shellHook = ''
    export JAVAFX_HOME=${pkgs.openjfx}
  '';
}
