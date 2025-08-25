{ config, hostname, ... }:
let
  hyprConfDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/wm/hyprland";
in

{
  home.file.".config/hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/hyprland-alpha.conf"
      else
        "${hyprConfDir}/hyprland-zeta.conf"
    );

  home.file.".config/hypr/decorration.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/decorration-alpha.conf"
      else
        "${hyprConfDir}/decorration-zeta.conf"
    );
  home.file.".config/hypr/current_theme.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/current_theme.conf";
}


