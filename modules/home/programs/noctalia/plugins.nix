{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.noctalia;
  tomlFormat = pkgs.formats.toml { };

  definitions = {
    discord-voice = {
      id = "raycursive/discord-voice";
      source = "community";
      packages = [
        pkgs.python3
        pkgs.discord
      ];
      settings.discord_binary = lib.getExe pkgs.discord;
      widgets.bar.type = "raycursive/discord-voice:bar";
    };
    bongocat = {
      id = "noctalia/bongocat";
      source = "official";
      packages = [ pkgs.evtest ];
      widgets.cat = {
        type = "noctalia/bongocat:cat";
        executable_path = lib.getExe pkgs.evtest;
      };
    };
    nix-search = {
      id = "knyrps/nix-search";
      source = "community";
      packages = [
        pkgs.nix-search-tv
        pkgs.fzf
        pkgs.xdg-utils
      ];
    };
    timer = {
      id = "noctalia/timer";
      source = "official";
      packages = [ ];
    };
    pomodoro = {
      id = "thepunkoff/pomodoro";
      source = "community";
      # The regular FFmpeg variant includes the ffplay executable.
      packages = [ pkgs.ffmpeg ];
      widgets.widget.type = "thepunkoff/pomodoro:widget";
    };
  };

  names = builtins.attrNames definitions;
  enabled = builtins.filter (name: cfg.plugins.${name}.enable) names;
  settingsFor =
    name: lib.recursiveUpdate (definitions.${name}.settings or { }) cfg.plugins.${name}.settings;
  widgetsFor =
    name: lib.recursiveUpdate (definitions.${name}.widgets or { }) cfg.plugins.${name}.widgets;
  widgetNames = lib.concatMap (name: builtins.attrNames (widgetsFor name)) names;

  pluginConfig = {
    plugins.enabled = map (name: definitions.${name}.id) enabled;
  }
  // lib.optionalAttrs (enabled != [ ]) {
    plugin_settings = builtins.listToAttrs (
      lib.concatMap (
        name:
        lib.optional (settingsFor name != { }) (lib.nameValuePair definitions.${name}.id (settingsFor name))
      ) enabled
    );
    widget = lib.foldl' lib.recursiveUpdate { } (map widgetsFor enabled);
  };

  pluginManifest = pkgs.writeText "noctalia-plugin-manifest.json" (
    builtins.toJSON {
      config = pluginConfig;
      sources = builtins.listToAttrs (
        map (name: lib.nameValuePair definitions.${name}.id definitions.${name}.source) enabled
      );
    }
  );

  statusCommand = pkgs.writeShellScriptBin "noctalia-config-status" ''
    exec ${lib.getExe pkgs.python3} ${./plugin-activation.py} \
      ${pluginManifest} ${lib.escapeShellArg config.xdg.stateHome} --status "$@"
  '';
in
{
  options.my.home.noctalia.plugins = lib.mapAttrs (_: plugin: {
    enable = lib.mkEnableOption "the Noctalia ${plugin.id} plugin and its dependencies";
    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = "Plugin settings merged with required defaults, written under plugin_settings.";
    };
    widgets = lib.mkOption {
      type = lib.types.attrsOf tomlFormat.type;
      default = { };
      description = "Overrides and additions to this plugin's named widget definitions.";
    };
  }) definitions;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.plugins.discord-voice.enable || lib.versionAtLeast pkgs.python3.version "3.11";
        message = "Noctalia Discord Voice requires Python newer than 3.10.";
      }
      {
        assertion = builtins.length widgetNames == builtins.length (lib.unique widgetNames);
        message = "Each Noctalia plugin widget must have a unique name.";
      }
    ];

    home.packages = [
      statusCommand
    ]
    ++ lib.unique (lib.concatMap (name: definitions.${name}.packages) enabled);

    xdg.configFile."noctalia/plugins.toml".source =
      tomlFormat.generate "noctalia-plugins.toml" pluginConfig;

    # Diagnose GUI overrides without changing the user's saved settings. Refresh
    # missing plugin code only if a Noctalia instance is already running.
    home.activation.noctaliaPlugins =
      lib.hm.dag.entryAfter
        [
          "noctaliaTheme"
          "installPackages"
        ]
        ''
          noctalia_plugin_sources="$(
            ${lib.getExe pkgs.python3} ${./plugin-activation.py} \
              ${pluginManifest} ${lib.escapeShellArg config.xdg.stateHome}
          )"

          if [[ ! -v DRY_RUN ]] && command -v noctalia >/dev/null 2>&1 \
              && noctalia msg status >/dev/null 2>&1; then
            if run noctalia msg config-reload; then
              while IFS= read -r noctalia_plugin_source; do
                [[ -n "$noctalia_plugin_source" ]] || continue
                if ! run noctalia msg plugins update "$noctalia_plugin_source"; then
                  warnEcho "warning: Noctalia could not refresh plugin source $noctalia_plugin_source; retry when online." >&2
                fi
              done <<< "$noctalia_plugin_sources"
            else
              warnEcho "warning: Noctalia could not reload its plugin configuration." >&2
            fi
          fi
        '';
  };
}
