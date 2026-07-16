{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    gcc
    pkg-config
    ninja
  ];

  buildInputs = with pkgs; [
    quickshell
    kdePackages.qtbase # Adds Qt6Core, Qt GUI, and Qt CMake configs
    kdePackages.qtdeclarative # Adds Qt6Qml
  ];

  shellHook = ''
    export QML2_IMPORT_PATH=${pkgs.quickshell}/lib/qt-6/qml
       echo "Ready to build! Run:"
        echo "  mkdir build && cd build"
        echo "  cmake -G Ninja .."
        echo "  ninja"
  '';
}



