{ config, ... }:
let
  assetsDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/assets";
in
{
  home.file."Pictures/Wall/" = {
    source = config.lib.file.mkOutOfStoreSymlink ("${assetsDir}/wallpapers");
  };
  home.file."Pictures/Pfp/" = {
    source = config.lib.file.mkOutOfStoreSymlink ("${assetsDir}/Pfp");
  };
}
