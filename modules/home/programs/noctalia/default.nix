{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  cfg = config.my.home.noctalia;
  noctaliaEnabled = osConfig != null && (osConfig.my.programs.noctalia.enable or false);
  noctaliaDir = "${config.xdg.configHome}/noctalia";
in
{
  options.my.home.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = noctaliaEnabled;
    description = "Manage Noctalia user configuration; defaults to the system feature's enable option.";
  };

  # WM modules attach their own integration only when both features are enabled.
  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      "noctalia/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.home.dotfilesDir}/modules/home/programs/noctalia/noctalia-config.toml";
      "noctalia/themes/black-mo.toml".source = ./themes/black-mo.toml;
      "noctalia/wallpapers/config.toml".source = ./wallpapers.toml;
      "noctalia/palettes/black-mo.json".source = ./black-mo.json;
    };

    # Home Manager never owns these runtime links. Activation only seeds them.
    home.activation.noctaliaTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      for slot in default.toml palettes/default.json; do
        case "$slot" in
          default.toml) target=${lib.escapeShellArg "${noctaliaDir}/themes/black-mo.toml"} ;;
          palettes/default.json) target=${lib.escapeShellArg "${noctaliaDir}/palettes/black-mo.json"} ;;
        esac
        dest=${lib.escapeShellArg noctaliaDir}/"$slot"
        if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
          run mkdir -p "$(dirname "$dest")"
          run ln -s "$target" "$dest"
        fi
      done
      dest=${lib.escapeShellArg "${config.home.homeDirectory}/.local/state/theme/wallpaper"}
      if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
        run mkdir -p "$(dirname "$dest")"
        run ln -s ${lib.escapeShellArg "${config.home.homeDirectory}/Pictures/Wallpapers/black.jpg"} "$dest"
      fi
    '';
  };
}
