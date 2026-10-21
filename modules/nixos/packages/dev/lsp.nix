{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.development.shared.enable {
    environment.systemPackages =
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

      ]);
  };
}
