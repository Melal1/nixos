{ config, lib, ... }:
{
  imports = [
    ./kitty.nix
  ];

  config = lib.mkIf config.programs.kitty.enable {
    home.file.".config/kitty/themes" = {
      source = ./themes;
      recursive = true; # copy everything inside
      force = true; # overwrite if exists
    };
  };
}
