{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  niriEnabled =
    if osConfig != null && (osConfig ? my.desktop.niri.enable) then
      osConfig.my.desktop.niri.enable
    else
      false;
in
{
  options.my.home.wm = {
    niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = niriEnabled;
      description = "Enable Niri window manager user configuration";
    };
  };

  imports = [
    ./niri
  ];
}
