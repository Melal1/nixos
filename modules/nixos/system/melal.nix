{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fish.enable = true;

  users.users.melal = {
    isNormalUser = true;
    description = "Melal";
    home = "/home/melal";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "uinput"
      "input"
      "adbusers"
      # "video" # Grants access to display hardware/video cards
      # "render" # Grants access to DRM render nodes (required for ROCm/AMD GPU compute)
    ]
    ++ lib.optional config.programs.gamemode.enable "gamemode";
  };
}
