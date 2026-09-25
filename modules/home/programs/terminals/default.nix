{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  osTerminals =
    if osConfig != null && (osConfig ? my.programs.terminals) then
      osConfig.my.programs.terminals
    else
      null;

  kittyEnabled =
    if osTerminals != null && (osTerminals ? kitty.enable) then osTerminals.kitty.enable else false;

  ghosttyEnabled =
    if osTerminals != null && (osTerminals ? ghostty.enable) then osTerminals.ghostty.enable else false;

  footEnabled =
    if osTerminals != null && (osTerminals ? foot.enable) then osTerminals.foot.enable else false;
in
{
  options.my.home.terminals = {
    kitty.enable = lib.mkOption {
      type = lib.types.bool;
      default = kittyEnabled;
      description = "Enable Kitty terminal user configuration";
    };
    ghostty.enable = lib.mkOption {
      type = lib.types.bool;
      default = ghosttyEnabled;
      description = "Enable Ghostty terminal user configuration";
    };
    foot.enable = lib.mkOption {
      type = lib.types.bool;
      default = footEnabled;
      description = "Enable Foot terminal user configuration";
    };
  };

  imports = [
    ./kitty
    ./ghostty
    ./foot
  ];
}
