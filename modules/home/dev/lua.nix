{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  options.my.home.dev.lua.enable = lib.mkEnableOption "Lua runtimes and editor tools";

  config = lib.mkIf config.my.home.dev.lua.enable {
    home.packages = fromSystem [
      pkgs.stylua
      unstable.emmylua-ls
      unstable.lua-language-server
    ];
  };
}
