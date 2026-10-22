{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.dev.csharp;
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.csharp = {
    enable = lib.mkEnableOption "the .NET SDK, C# tools and language server";
    avalonia.enable = lib.mkEnableOption "the .NET SDK and native dependencies for Avalonia";
  };

  config = lib.mkIf cfg.enable {
    home.packages = fromSystem [ pkgs.roslyn-ls ];
  };
}
