{ config, lib, ... }:

let
  waybarDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/bars/waybar";
in
{
  config = {
    home.file.".config/waybar/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink (
        if config.my.home.waybar.theme == "alpha-v" then
          "${waybarDir}/config-alpha-v"
        else
          "${waybarDir}/config-zeta"
      );

    home.file.".config/waybar/style.css".source =
      config.lib.file.mkOutOfStoreSymlink (
        if config.my.home.waybar.theme == "alpha-v" then
          "${waybarDir}/style-alpha-v.css"
        else
          "${waybarDir}/style.css"
      );
  };
}
