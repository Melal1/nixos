{ config, lib, ... }:

let
  waybarDir = "${config.my.home.dotfilesDir}/modules/home/programs/bars/waybar";
  theme = config.my.home.waybar.theme;
in
{
  options.my.home.waybar.theme = lib.mkOption {
    type = lib.types.enum [
      "snowflake-v"
      "rusty"
    ];
    default = "rusty";
    description = "Waybar config variant";
  };

  config = lib.mkIf config.my.home.wm.hyprland.enable {
    home.file.".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink (
      if theme == "snowflake-v" then
        "${waybarDir}/config-station-snowflake-v"
      else
        "${waybarDir}/config-station-rusty"
    );

    home.file.".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink (
      if theme == "snowflake-v" then
        "${waybarDir}/style-station-snowflake-v.css"
      else
        "${waybarDir}/style-station.css"
    );
  };
}
