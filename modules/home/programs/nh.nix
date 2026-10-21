{ config, lib, ... }:
lib.mkIf config.programs.nh.enable {
  programs.nh = {
    flake = "${config.home.homeDirectory}/.dotfiles/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
