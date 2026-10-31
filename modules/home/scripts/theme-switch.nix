# theme-switch — switch terminal themes + wallpapers through the indirection
# links, no Nix rebuild required.
#
#   theme-switch <name> [wallpaper-name | --random]
#
# Themes live in the assets repo as one directory per theme with slot-named
# symlinks (missing slots are skipped, so themes can be partial):
#
#   ~/.local/share/assets/themes/<name>/
#     kitty        -> (kitty theme file in the dotfiles repo)
#     ghostty      -> (ghostty theme file in the dotfiles repo)
#     niri         -> (KDL theme fragment)
#     noctalia     -> (TOML file with a [theme] section, custom_palette = "default")
#     noctalia-palette -> (custom palette JSON)
#     video        -> (video file in the assets repo)
#     wallpaper    -> (single image in the assets repo)
#     wallpapers/                # multi-wallpaper themes: dir of links
#       default.jpg -> ...
#       river.jpg   -> ...
#
# Wallpaper resolution for multi-wallpaper themes (wallpapers/ dir):
#   1. explicit <wallpaper-name> argument (exact or substring match)
#   2. --random picks one at random
#   3. otherwise the default.* convention
#
# After re-pointing the links the script applies the selected image or video
# through skwd-wall, then reloads kitty (SIGUSR1) and ghostty (SIGUSR2).
{ pkgs }:

pkgs.writeShellScriptBin "theme-switch" ''
  export PATH=${
    pkgs.lib.makeBinPath [
      pkgs.coreutils
      pkgs.findutils
      pkgs.procps
      pkgs.systemd
    ]
  }:$PATH
  ${builtins.readFile ./theme-switch.sh}
''
