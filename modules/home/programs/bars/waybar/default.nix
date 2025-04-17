{ config, inputs, ... }:

# TODO: not hardcoded
let
  waybarDir = "/home/melal/.dotfiles/nixos/modules/home/programs/bars/waybar";
in {
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${waybarDir}/config";

  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${waybarDir}/style.css";
}

