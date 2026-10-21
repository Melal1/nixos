{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Global toolchain selections live in hosts/snowflake/default.nix.
  config = lib.mkIf config.my.packages.development.host.enable {
    environment.systemPackages = with pkgs; [
      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      prettier
      eslint
    ];
  };
}
