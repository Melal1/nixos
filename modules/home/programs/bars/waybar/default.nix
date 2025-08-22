{ self, config, hostname, ... }:

let
  waybarDir = "${self}/modules/home/programs/bars/waybar";
  hostName = hostname;
in
{
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostName == "alpha" then
        "${waybarDir}/config-alpha"
      else
        "${waybarDir}/config-zeta"
    );

  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${waybarDir}/style.css";
}

