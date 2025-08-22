{ self, config, hostname, ... }:

let
  sDir = "${self}/modules/home/programs/wm/hyprland";
  hostName = hostname;
in
{
  home.file.".config/hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${sDir}/hyprland.conf";
  home.file.".config/hypr/decorration.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${sDir}/decorration.conf";
  home.file.".config/hypr/current_theme.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${sDir}/current_theme.conf";
}

