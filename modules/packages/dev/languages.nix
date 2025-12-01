{ pkgs, config, unstable, ... }: {
  environment.systemPackages = (with pkgs; [

    ### ──────────────────────
    ### Programming Languages
    ### ──────────────────────
    cargo # Rust package manager and build tool
    python314 # Python interpreter
    nodejs # JavaScript runtime
    typescript # Typescript
    go # Go programming language
    vscode-extensions.ms-vscode.cpptools
    gdb
    lua
    ### ──────────────────────
    ### Compilers
    ### ──────────────────────
  ])
  ++
  (with unstable; [
    clang # LLVM-based C/C++ compiler
    gcc # GNU C Compiler
  ])
  ++
  (if config.networking.hostName == "alpha" then

    (with pkgs;
    [
    jdk21_headless
    ])
  else
    [ ]);
}

