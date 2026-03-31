{ pkgs }:

let
  libs = [
    # I tried moving some of the libraries below here to
    # exclude them from $LD_LIBRARY_PATH.
  ];
  ld-lib-path-libs = [
    # fatal error if the following libs are removed from $LD_LIBRARY_PATH:
    pkgs.xorg.libXtst
    pkgs.glib
    # non-fatal error (backtrace displayed, but GUI still opens) if
    # the following libs are removed from $LD_LIBRARY_PATH:
    pkgs.xorg.libXxf86vm
    pkgs.libGL
  ];
in
pkgs.mkShell {
  packages = [
    pkgs.jdk
    pkgs.gradle
  ] ++ libs ++ ld-lib-path-libs;
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath ld-lib-path-libs}
  '';
}
