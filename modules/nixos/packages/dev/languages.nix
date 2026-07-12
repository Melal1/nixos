{ pkgs, config, unstable, ... }: {
  environment.systemPackages = (with pkgs; [
    vscode-extensions.ms-vscode.cpptools
    gdb
    lua

    # Build tools
    cmake
    gradle
    gnumake
    cargo # Rust package manager and build tool
    bun
  ])
  ++ (
    if config.networking.hostName == "alpha" then
      (with pkgs; [
        python3 # Python interpreter
        nodejs # JavaScript runtime
        typescript # Typescript
        kdePackages.qtdeclarative
        premake5
        go # Go programming language
      ])
    else if config.networking.hostName == "zeta" then
      [ ]
    else
      [ ]
  ) ++
  (with unstable; [
    clang
    gcc
  ]);
  programs.java = {
    enable = true;
    package = pkgs.jdk21_headless.override { enableJavaFX = true; };
  };
}
