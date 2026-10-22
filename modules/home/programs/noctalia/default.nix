{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.my.home.noctalia;
  noctaliaDir = "${config.xdg.configHome}/noctalia";
in
{
  imports = [ ./plugins.nix ];

  options.my.home.noctalia = {
    enable = lib.mkEnableOption "the Noctalia shell, configuration and selected plugins";
    optimize_for_arch = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Build the shell for the host CPU using pkgs.optimizeForArch.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.optimizeForArch {
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        inherit (cfg) optimize_for_arch;
      };
      description = "Noctalia shell package.";
    };
    configFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.my.home.dotfilesDir}/modules/home/programs/noctalia/minimal-config.toml";
      description = "Mutable main TOML file in the user's checkout.";
    };
  };

  # WM modules attach their own integration only when both features are enabled.
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile = {
      "noctalia/config.toml".source = config.lib.file.mkOutOfStoreSymlink cfg.configFile;
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
