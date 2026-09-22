{ user }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.fullName;
    home = user.homeDirectory;
    shell = pkgs.${user.shell};
    extraGroups = user.extraGroups ++ lib.optional config.programs.gamemode.enable "gamemode";
    # extraGroups = user.extraGroups ++ lib.optional config.my.hardware.androidWebcam.enable "adbusers";
  };
}
// lib.optionalAttrs (user.shell == "fish") {
  programs.fish.enable = true;
}
