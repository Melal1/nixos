{
  pkgs,
  unstable,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
      vscode-extensions.ms-vscode.cpptools
      gdb
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
      emmylua-ls
      lua-language-server

    ]);
}
