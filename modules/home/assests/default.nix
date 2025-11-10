{ config, ... }:
let
  assestsDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/assests";
in
{
  home.file."Pictures/Wall/" = {
    source = config.lib.file.mkOutOfStoreSymlink ("${assestsDir}/wallpapers");
  };
  home.file."Pictures/Pfp/" = {
    source = config.lib.file.mkOutOfStoreSymlink ("${assestsDir}/Pfp");
  };
}
