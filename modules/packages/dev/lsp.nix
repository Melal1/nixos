{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    shellcheck                          # Shell script linter
    shfmt                               # Shell script formatter
    stylua                              # Lua code formatter
    lua-language-server                 # Lua LSP
    bash-language-server                # Bash LSP
    typescript-language-server
    nil                                 # Nix language LSP
    nixpkgs-fmt                         # Formatter for Nix expressions
    tailwindcss-language-server         # Tailwind CSS LSP
    vscode-langservers-extracted        # HTML, CSS, JSON, etc. LSPs
    clang-tools                         # Tools like clangd (C/C++ LSP)
    nodePackages.prettier
    nodePackages.eslint
  ];
}


