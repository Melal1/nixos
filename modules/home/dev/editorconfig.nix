{ config, lib, ... }:
let
  anyParent = lib.any (group: group.enable) (builtins.attrValues config.my.home.dev);
in
{
  home.file.".editorconfig" = lib.mkIf anyParent {
    text = ''
      [*]
      max_line_length = 120
    '';
  };
}
