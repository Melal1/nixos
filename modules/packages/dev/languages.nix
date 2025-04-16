{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [

    ### ──────────────────────
    ### Programming Languages
    ### ──────────────────────
    cargo           # Rust package manager and build tool
    python3         # Python interpreter
    nodejs          # JavaScript runtime
    go              # Go programming language

    ### ──────────────────────
    ### Compilers
    ### ──────────────────────
    gcc             # GNU C Compiler
    clang           # LLVM-based C/C++ compiler
  ];
}

