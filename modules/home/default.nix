{ lib, ... }:
{
  options.my.home = {
    waybar.theme = lib.mkOption {
      type = lib.types.str;
      default = "zeta";
      description = "Theme for Waybar config (e.g., 'alpha-v' or 'zeta')";
    };
    scripts.disableHyprlandEffects = lib.mkEnableOption "Disable Hyprland effects script";
  };

  imports = [
    ./programs/terminals
    ./shell
    ./dev
    ./scripts
    ./programs/utilities
    ./programs/wm
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
