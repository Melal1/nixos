{ config, hostname, ... }:
let
  hyprConfDir = "${config.my.home.dotfilesDir}/modules/home/programs/wm/hyprland";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/hypr/hyprland.conf".source = link "${hyprConfDir}/source.conf";
    ".config/hypr/autostart.conf".source = link "${hyprConfDir}/autostart.conf";
    ".config/hypr/input.conf".source = link "${hyprConfDir}/input.conf";
    ".config/hypr/misc.conf".source = link "${hyprConfDir}/misc.conf";
    ".config/hypr/programs.conf".source = link "${hyprConfDir}/programs.conf";
    ".config/hypr/windowrules.conf".source = link "${hyprConfDir}/windowrules.conf";
    ".config/hypr/keybinds/keybindings.conf".source = link "${hyprConfDir}/keybinds/keybindings.conf";

    # Host-specific fragments: files are named after the host, so a new host
    # only needs matching <hostname>.conf files, no module changes.
    ".config/hypr/keybinds/host-keybinds.conf".source = link "${hyprConfDir}/keybinds/${hostname}-keybinds.conf";
    ".config/hypr/decorations/host.conf".source = link "${hyprConfDir}/decorations/${hostname}-decorration.conf";
    ".config/hypr/animations/host.conf".source = link "${hyprConfDir}/animations/${hostname}.conf";
    ".config/hypr/monitors/host.conf".source = link "${hyprConfDir}/monitors/${hostname}.conf";
    ".config/hypr/workspaces/host.conf".source = link "${hyprConfDir}/workspaces/${hostname}.conf";
  };
}
