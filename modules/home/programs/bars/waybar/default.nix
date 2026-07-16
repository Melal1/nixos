{ config, lib, windowManager, ... }:

let
  waybarDir = "${config.my.home.dotfilesDir}/modules/home/programs/bars/waybar";
  theme = config.my.home.waybar.theme;
in
{
  options.my.home.waybar.theme = lib.mkOption {
    type = lib.types.enum [ "alpha-v" "zeta" ];
    default = "zeta";
    description = "Waybar config variant";
  };

  config = lib.mkIf (windowManager == "hyprland") {
    home.file.".config/waybar/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink (
        if theme == "alpha-v"
        then "${waybarDir}/config-station-alpha-v"
        else "${waybarDir}/config-station-zeta"
      );

    home.file.".config/waybar/style.css".source =
      config.lib.file.mkOutOfStoreSymlink (
        if theme == "alpha-v"
        then "${waybarDir}/style-station-alpha-v.css"
        else "${waybarDir}/style-station.css"
      );
  };
}
