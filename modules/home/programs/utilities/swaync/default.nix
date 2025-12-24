{ config, ... }:
{

  home.file.".config/swaync/config.json" = {
    source = config.lib.file.mkOutOfStoreSymlink (./config.json);
  };
  home.file.".config/swaync/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink (./style.css);
  };
  home.file.".config/swaync/notifications.css" = {
    source = config.lib.file.mkOutOfStoreSymlink (./notifications.css);
  };
  home.file.".config/swaync/central_control.css" = {
    source = config.lib.file.mkOutOfStoreSymlink (./central_control.css);
  };
  home.file."Pictures/icons" = {
    source = config.lib.file.mkOutOfStoreSymlink ./icons;
    recursive = true;
  };

}
