{ config, hostname, ... }:
let
  hyprConfDir = "${config.home.homeDirectory}/.dotfiles/nixos/modules/home/programs/wm/hyprland";
in
{
  home.file.".config/hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/source.conf";

  home.file.".config/hypr/autostart.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/autostart.conf";

  home.file.".config/hypr/current_theme.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/current_theme.conf";

  home.file.".config/hypr/input.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/input.conf";

  home.file.".config/hypr/misc.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/misc.conf";

  home.file.".config/hypr/programs.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/programs.conf";


  home.file.".config/hypr/keybinds/keybindings.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprConfDir}/keybinds/keybindings.conf";

  home.file.".config/hypr/keybinds/host-keybinds.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/keybinds/alpha-keybinds.conf"
      else if hostname == "zeta" then
        "${hyprConfDir}/keybinds/zeta-keybinds.conf"
      else
        "/dev/null"
    );

  home.file.".config/hypr/decorations/host.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/decorations/alpha-decorration.conf"
      else if hostname == "zeta" then
        "${hyprConfDir}/decorations/zeta-decorration.conf"
      else
        "/dev/null"
    );

  home.file.".config/hypr/animations/host.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/animations/alpha.conf"
      else if hostname == "zeta" then
        "${hyprConfDir}/animations/zeta.conf"
      else
        "/dev/null"
    );

  home.file.".config/hypr/monitors/host.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/monitors/alpha.conf"
      else if hostname == "zeta" then
        "${hyprConfDir}/monitors/zeta.conf"
      else
        "/dev/null"
    );

  home.file.".config/hypr/workspaces/host.conf".source =
    config.lib.file.mkOutOfStoreSymlink (
      if hostname == "alpha" then
        "${hyprConfDir}/workspaces/alpha.conf"
      else if hostname == "zeta" then
        "${hyprConfDir}/workspaces/zeta.conf"
      else
        "/dev/null"
    );
}

