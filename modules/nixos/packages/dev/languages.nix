{
  pkgs,
  config,
  lib,
  unstable,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
      vscode-extensions.ms-vscode.cpptools
      gdb
      lua
      netcoredbg

      # Build tools
      gradle
      gnumake
      cargo # Rust package manager and build tool
      bun
      # dotnet-sdk_9
      dotnet-sdk_10
      csharpier
      easydotnet
      nodejs # JavaScript runtime
    ])
    ++ lib.optionals (config.networking.hostName == "snowflake") (
      with pkgs;
      [
        python3 # Python interpreter
        typescript # Typescript
        kdePackages.qtdeclarative
        premake5
        go # Go programming language
      ]
    )
    ++ (with unstable; [
      clang
      gcc
      cmake
      luajit
    ]);
  programs.java = {
    enable = true;
    package = pkgs.jdk21_headless.override { enableJavaFX = true; };
  };
}
