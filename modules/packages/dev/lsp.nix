{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [

    # --- Shell / Bash ---
    shellcheck                          # Linter for shell scripts
    shfmt                               # Formatter for shell scripts
    bash-language-server                # LSP for Bash

    # --- Lua ---
    stylua                              # Formatter for Lua
    lua-language-server                 # LSP for Lua

    # --- Python ---
    pyright                             # LSP for Python
    ruff                                # Linter for Python
    mypy

    # --- JavaScript / TypeScript / Web ---
    typescript-language-server          # LSP for TypeScript & JavaScript
    tailwindcss-language-server         # LSP for Tailwind CSS
    vscode-langservers-extracted        # LSPs for HTML, CSS, JSON, etc.
    nodePackages.prettier               # Formatter for JS, TS, JSON, etc.
    nodePackages.eslint                 # Linter for JavaScript / TypeScript

    # --- C / C++ ---
    clang-tools                         # Includes clangd (LSP) and other tools

    # --- Nix ---
    nil                                 # LSP for Nix language
    nixpkgs-fmt                         # Formatter for Nix expressions

    # --- json ---
    nodePackages_latest.vscode-json-languageserver

    # --- General / Misc ---
    harper                              # English grammar and style checker
  ];
}

