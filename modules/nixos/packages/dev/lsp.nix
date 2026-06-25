{ pkgs, config, unstable, ... }: {
  environment.systemPackages = (with pkgs; [
    cmake-language-server
    shellcheck
    shfmt
    bash-language-server
    stylua
    lua-language-server
    nil
    nixpkgs-fmt
    vscode-json-languageserver
    jdt-language-server
    pyright
    ruff
    mypy
    harper
  ])
  ++ (
    if config.networking.hostName == "alpha" then
      (with pkgs; [
        typescript-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        prettier
        eslint
      ])
    else if config.networking.hostName == "zeta" then
      [ ]
    else
      [ ]
  )
  ++ (with unstable; [
    clang-tools
  ]);
  programs.nix-ld.enable = true;
}
