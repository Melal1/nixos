{ config, ... }:
{

  home.file.".config/swaync/config.json" = {
    source = config.lib.file.mkOutOfStoreSymlink (./config.json);
  };
  home.file.".config/swaync/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink (./style.css);
  };
  home.file.".config/swaync/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink (./themes);
    recursive = true;
  };
  home.file."Pictures/icons" = {
    source = config.lib.file.mkOutOfStoreSymlink ./icons;
    recursive = true;
  };

}
