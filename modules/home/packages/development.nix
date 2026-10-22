{
  pkgs,
  unstable,
  lib,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    (with pkgs; [
      vscode-extensions.ms-vscode.cpptools
      gdb
      watchman
      yarn
      bear
      netcoredbg
      csharpier
      easydotnet
      cmake-language-server
      shellcheck
      shfmt
      bash-language-server
      stylua
      nil
      nixpkgs-fmt
      vscode-json-languageserver
      jdt-language-server
      pyright
      ruff
      libxml2
      mypy
      harper
      roslyn-ls
      clang-tools
    ])
    ++ (with unstable; [
      tree-sitter
      emmylua-ls
      lua-language-server

    ])
  );
}
