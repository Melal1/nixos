{ config,  ... }:
let
hyprConfDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/wm/hyprland";
in

{
  home.file.".config/hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/hyprland.conf";
  home.file.".config/hypr/decorration.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/decorration.conf";
  home.file.".config/hypr/current_theme.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/current_theme.conf";
}


