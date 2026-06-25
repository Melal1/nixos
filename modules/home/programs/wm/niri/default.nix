{ config, hostname, ... }:
let
  niriDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/wm/niri";
in

{
  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
}
