{ pkgs }:

pkgs.mkShell {
  packages = with pkgs ;[ quickshell kdePackages.qtdeclarative ];

  shellHook = ''
    export QML2_IMPORT_PATH=${pkgs.quickshell}/lib/qt-6/qml
  '';
}



