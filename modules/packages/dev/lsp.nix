{ pkgs, config, unstable, ... }: {
  environment.systemPackages = (with pkgs;[
    # --- C / C++ ---
    # clang-tools # Includes clangd (LSP) and other tools
    cmake-language-server

    # --- Shell / Bash ---
    shellcheck # Linter for shell scripts
    shfmt # Formatter for shell scripts
    bash-language-server # LSP for Bash

    # --- Lua ---
    stylua # Formatter for Lua
    lua-language-server # LSP for Lua



    # --- Nix ---
    nil # LSP for Nix language
    nixpkgs-fmt # Formatter for Nix expressions

    # --- json ---
    nodePackages_latest.vscode-json-languageserver

    # --- java ---
    jdt-language-server


    # --- General / Misc ---
    harper # English grammar and style checker


  ])
  ++ (
    if config.networking.hostName == "alpha" then
      (with pkgs; [
        # --- Python ---
        pyright # LSP for Python
        ruff # Linter for Python
        mypy
        # --- JavaScript / TypeScript / Web ---
        typescript-language-server # LSP for TypeScript & JavaScript
        tailwindcss-language-server # LSP for Tailwind CSS
        vscode-langservers-extracted # LSPs for HTML, CSS, JSON, etc.
        nodePackages.prettier # Formatter for JS, TS, JSON, etc.
        nodePackages.eslint # Linter for JavaScript / TypeScript
      ])
    else if config.networking.hostName == "zeta" then
      (with pkgs; [
      ])
    else
      [ ]
  )
  ++ (with unstable ;[
    clang-tools
  ])
  ;
  programs.nix-ld.enable = true;
}



