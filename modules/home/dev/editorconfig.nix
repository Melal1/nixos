{ config, lib, ... }:
{
  home.file.".editorconfig" = lib.mkIf config.my.home.development.enable {
    text = ''
      [*]
      max_line_length = 120
    '';
  };
}
