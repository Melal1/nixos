{ pkgs, config, unstable, lib, ... }: {
  config = lib.mkIf config.my.groups.dev.enable {
    environment.systemPackages = (with pkgs;[
      cmake-language-server
      shellcheck shfmt bash-language-server
      stylua lua-language-server
      nil nixpkgs-fmt
      nodePackages_latest.vscode-json-languageserver
      jdt-language-server
      pyright ruff mypy
      harper
      typescript-language-server tailwindcss-language-server
      vscode-langservers-extracted nodePackages.prettier nodePackages.eslint
    ]) ++ (with unstable; [
      clang-tools
    ]);
    programs.nix-ld.enable = true;
  };
}
