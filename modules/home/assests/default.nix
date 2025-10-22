{ config, ... }:
{
  home.file."Pictures/Wall/" = {
    source = config.lib.file.mkOutOfStoreSymlink ./wallpapers;
    recursive = true;
  };
}
