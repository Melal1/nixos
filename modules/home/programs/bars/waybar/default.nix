{ config, hostname, ... }:

let
  waybarDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/bars/waybar";
in
{
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${waybarDir}/config-alpha-v"
      else
        "${waybarDir}/config-zeta"
    );

  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${waybarDir}/style-alpha-v.css";
}

