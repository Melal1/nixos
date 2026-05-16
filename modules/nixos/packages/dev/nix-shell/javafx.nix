{ pkgs }:

let
  # Choose the version that matches your JDK requirements
  javafx-pkg = pkgs.openjfx21; 

  libs = [
    # General build dependencies
  ];

  ld-lib-path-libs = [
    # Required for the JavaFX GUI to actually render on NixOS
    pkgs.xorg.libXtst
    pkgs.glib
    pkgs.xorg.libXxf86vm
    pkgs.libGL
  ];
in
pkgs.mkShell {
  packages = [
    pkgs.jdk
    pkgs.gradle
    javafx-pkg
  ] ++ libs ++ ld-lib-path-libs;

  shellHook = ''
    # Fixes the "cannot find shared libraries" runtime errors
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath ld-lib-path-libs}:$LD_LIBRARY_PATH"

    # Helps some LSPs and Gradle plugins locate the JavaFX SDK path
    export JAVAFX_HOME="${javafx-pkg}"
    
    echo "JavaFX Dev Environment Loaded"
    echo "JDK Path: $(which java)"
  '';
}
