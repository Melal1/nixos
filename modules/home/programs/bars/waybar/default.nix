{ self, config, hostname, ... }:

let
  waybarDir = "${self}/modules/home/programs/bars/waybar";
in
{
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${waybarDir}/config-alpha"
      else
        "${waybarDir}/config-zeta"
    );

  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${waybarDir}/style.css";
}

