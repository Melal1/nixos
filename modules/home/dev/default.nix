{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.my.home.dev;
  anyParent = lib.any (group: group.enable) (builtins.attrValues cfg);
  selections = {
    cpp = cfg.cpp.enable;
    audio = cfg.cpp.audio.enable;
    dpp = cfg.cpp.dpp.enable;
    fmt = cfg.cpp.fmt.enable;
    ncurses = cfg.cpp.ncurses.enable;
    qksh = cfg.cpp.qksh.enable;
    dotnet = cfg.csharp.enable;
    avalonia = cfg.csharp.avalonia.enable;
    py = cfg.python.enable;
    py-science = cfg.python.science.enable;
    nodejs22 = cfg.javascript.enable;
    lua = cfg.lua.enable;
    go = cfg.go.enable;
    rust = cfg.rust.enable;
    javafx = cfg.java.javafx.enable;
  };
  selected = builtins.attrNames (lib.filterAttrs (_: enabled: enabled) selections);
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  imports = [
    ./cpp.nix
    ./csharp.nix
    ./python.nix
    ./javascript.nix
    ./lua.nix
    ./go.nix
    ./rust.nix
    ./java.nix
    ./nix.nix
    ./shell.nix
    ./json.nix
    ./xml.nix
    ./text.nix
    ./editorconfig.nix
  ];

  config = lib.mkMerge [
    (import ./toolchain-packages.nix { inherit lib pkgs; } selected)
    (lib.mkIf anyParent {
      home.packages = fromSystem [ unstable.tree-sitter ];
    })
  ];
}
