{ pkgs, config, unstable, ... }: {
  environment.systemPackages = (with pkgs; [

    ### ──────────────────────
    ### Programming Languages
    ### ──────────────────────
    vscode-extensions.ms-vscode.cpptools
    gdb
    lua
  ])
  ++ (
    if config.networking.hostName == "alpha" then
      (with pkgs; [
        cargo # Rust package manager and build tool
        python3 # Python interpreter
        nodejs # JavaScript runtime
        typescript # Typescript
        kdePackages.qtdeclarative
        go # Go programming language
      ])
    else if config.networking.hostName == "zeta" then
      (with pkgs; [
      ])
    else
      [ ]
  ) ++
  (with unstable ;[
    clang
    gcc
  ]);

}

