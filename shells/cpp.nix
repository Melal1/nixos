{ pkgs }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gcc
    clang
    clang-tools
    gnumake
    cmake
    ninja
    pkg-config
    premake5
    gdb
  ];

  buildInputs = with pkgs; [
    fmt
    nlohmann_json
  ];
}
