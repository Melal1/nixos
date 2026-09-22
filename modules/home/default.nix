{ config, lib, ... }:
{
  options.my.home.dotfilesDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles/nixos";
    description = "Absolute path to this repo checkout, used for out-of-store symlinks.";
  };

  imports = [
    ./programs
    ./shell
    ./dev
    ./scripts
    ./gtk.nix
  ];

  config = {
    programs.home-manager.enable = true;
  };
}
