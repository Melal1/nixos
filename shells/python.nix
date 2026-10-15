{ pkgs }:

let
  runtimeLibs = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glib
    libGL
    libsndfile
  ];
in
pkgs.mkShell {
  # Also expose libraries referenced only by the hook to host package selection.
  passthru.runtimePackages = runtimeLibs;

  packages = with pkgs; [
    uv
    python313
  ];

  shellHook = ''
    # Shared libraries for uv / PyPI wheels
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    unset PYTHONPATH
  '';
}
