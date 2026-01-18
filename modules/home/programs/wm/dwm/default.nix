{ config, ... }:
{

  home.file.".xprofile".source =
    config.lib.file.mkOutOfStoreSymlink ./.xprofile;
}

