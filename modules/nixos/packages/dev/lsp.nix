{
  pkgs,
  config,
  lib,
  unstable,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [
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
      libxml2
      mypy
      harper
      roslyn-ls
    ])
    ++ lib.optionals (config.networking.hostName == "snowflake") (
      with pkgs;
      [
        typescript-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        prettier
        eslint
      ]
    )
    ++ (with unstable; [
      clang-tools
    ]);
  programs.nix-ld.enable = true;
}
