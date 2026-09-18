{ config, lib, ... }:
{
  imports = [
    ./kitty.nix
  ];

  config = lib.mkIf config.my.home.terminals.kitty.enable {
    home.file.".config/kitty/themes" = {
      source = ./themes;
      recursive = true; # copy everything inside
      force = true; # overwrite if exists
    };
  };
}
