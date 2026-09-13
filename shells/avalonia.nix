{ pkgs }:

let
  # List all runtime dynamic libraries needed by Avalonia & SkiaSharp
  libList = with pkgs; [
    fontconfig
    libGL
    libxkbcommon
    libX11
    libICE
    libSM
    libXext
    libXcursor
    libXrandr
    libXi
    libXrender
    freetype
    icu
    openssl
    zlib
    stdenv.cc.cc.lib
  ];
in
pkgs.mkShell {
  packages = [
    pkgs.dotnet-sdk_10
  ] ++ libList;

  shellHook = ''
    # Dynamically point LD_LIBRARY_PATH to native shared object (.so) files
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libList}:$LD_LIBRARY_PATH"

    echo "Avalonia .NET 10 environment loaded!"

    # 1. Check if global Avalonia dotnet templates are installed
    if ! dotnet new list avalonia.app >/dev/null 2>&1; then
      echo ""
      echo "[INFO] Avalonia dotnet templates are not installed globally."
      echo "To install the project templates, run:"
      echo "  dotnet new install Avalonia.Templates"
    fi

    # 2. Check current directory for .csproj and Avalonia dependency
    CSPROJ_FILE=$(ls *.csproj 2>/dev/null | head -n 1)

    if [ -n "$CSPROJ_FILE" ]; then
      if ! grep -qi "PackageReference.*Avalonia" "$CSPROJ_FILE"; then
        echo ""
        echo "[WARNING] Avalonia NuGet package is not installed in '$CSPROJ_FILE'."
        echo "Run the following command to add the latest version from NuGet.org:"
        echo "  dotnet add package Avalonia"
        echo ""
      fi
    else
      echo ""
      echo "No .csproj file found. Create a project with: dotnet new avalonia.app"
    fi
  '';
}
