{ config, lib, ... }:
{
  options.my.home.dotfilesDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles/nixos";
    description = "Absolute path to this repo checkout, used for out-of-store symlinks.";
  };

  imports = [
    ./programs/terminals
    ./shell
    ./dev
    ./scripts
    ./programs/utilities
    ./programs/wm
    ./programs/bars/waybar
    ./gtk.nix
    ./assets
  ];

  config = {
    home.username = "melal";
    home.homeDirectory = "/home/melal/";
    programs.home-manager.enable = true;

    home.stateVersion = "24.11";
  };
}
