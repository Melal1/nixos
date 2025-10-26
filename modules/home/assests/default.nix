{ config, ... }:
{
  home.file."Pictures/Wall/" = {
    source = config.lib.file.mkOutOfStoreSymlink ./wallpapers;
    recursive = true;
  };
  home.file."Pictures/Pfp/" = {
    source = config.lib.file.mkOutOfStoreSymlink ./Pfp;
    recursive = true;
  };
}
