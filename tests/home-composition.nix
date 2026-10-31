# Exercise the reusable Home entrypoint without importing a real host's choices.
{ self, inputs }:
let
  lib = inputs.nixpkgs.lib;
  realHome = self.homeConfigurations."melal@rusty";
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  core = inputs.home-manager.lib.homeManagerConfiguration {
    inherit (realHome) pkgs;
    extraSpecialArgs = {
      inherit inputs unstable;
      hostname = "core-fixture";
      osConfig = self.nixosConfigurations.rusty.config;
    };
    modules = [ ../modules/home ];
  };
  desktop = core.extendModules {
    modules = [ ../modules/home/presets/desktop.nix ];
  };
  loadOverrides = import ../modules/home/lib/load-overrides.nix lib;
  overrideModules = loadOverrides ./fixtures/host-overrides;
  directoryOverrides = desktop.extendModules {
    modules = overrideModules;
  };
  noctaliaDefaults = desktop.extendModules {
    modules = [ { my.home.noctalia.enable = true; } ];
  };
  development = core.extendModules {
    modules = [ ../modules/home/presets/development.nix ];
  };
  overrides = desktop.extendModules {
    modules = [
      {
        programs.kitty.enable = false;
        programs.foot.settings.main.font = "monospace:size=12";
        programs.fish.shellAbbrs.h-r = "home-fixture";
        my.home.media.enable = false;
      }
    ];
  };
  cppOff = development.extendModules {
    modules = [ { my.home.dev.cpp.enable = false; } ];
  };
  explicitDpp = cppOff.extendModules {
    modules = [ { my.home.dev.cpp.dpp.enable = true; } ];
  };
  features = desktop.extendModules {
    modules = [
      ../modules/home/presets/development.nix
      {
        my.home.noctalia.enable = true;
        my.home.dev = {
          javascript.enable = true;
          go.enable = true;
          rust.enable = true;
          csharp.avalonia.enable = true;
          python.science.enable = true;
        };
      }
    ];
  };
  bundles = inputs.home-manager.lib.homeManagerConfiguration {
    inherit (realHome) pkgs;
    extraSpecialArgs = { inherit inputs unstable; };
    modules = [
      {
        home.username = "melal";
        home.homeDirectory = "/home/melal";
        home.stateVersion = "24.11";
        nixpkgs.config.allowUnfree = true;
      }
      ../modules/home/packages/cli.nix
      ../modules/home/packages/desktop-apps.nix
      ../modules/home/packages/io.nix
      ../modules/home/packages/database-clients.nix
      ../modules/home/packages/container-clients.nix
    ];
  };
  featurePaths = map (p: p.outPath) features.config.home.packages;
  # Compare contributions from our lists, excluding Home Manager's own defaults
  # (man pages, MIME data and similar infrastructure).
  sharedPackages = lib.concatMap (definition: definition.value) (
    builtins.filter (
      definition: lib.hasInfix "/modules/home/packages/" definition.file
    ) bundles.options.home.packages.definitionsWithLocations
  );
  systemPaths =
    lib.concatMap
      (host: map (p: p.outPath) self.nixosConfigurations.${host}.config.environment.systemPackages)
      [
        "rusty"
        "snowflake"
      ];
  checks = {
    core-keeps-personal-shell = core.config.programs.fish.enable && core.config.programs.git.enable;
    core-has-no-desktop = !core.config.my.home.desktop.enable && !core.config.my.home.wm.niri.enable;
    core-has-no-media = !core.config.my.home.media.enable;
    core-has-no-graphical-terminals =
      !core.config.programs.kitty.enable && !core.config.programs.foot.enable;
    core-has-no-hardware-clients =
      !core.config.my.home.keyboardTools.enable && !core.config.my.home.bluetoothClient.enable;
    core-has-no-development = lib.all (group: !group.enable) (
      builtins.attrValues core.config.my.home.dev
    );
    core-has-no-browser = !(core.config.home.sessionVariables ? BROWSER);
    desktop-keeps-optional-features-off =
      !desktop.config.my.home.noctalia.enable && !desktop.config.programs.ghostty.enable;
    missing-override-folder-is-optional = loadOverrides ./fixtures/host-overrides/missing == [ ];
    override-loader-imports-only-top-level-nix =
      map builtins.baseNameOf overrideModules == [ "foot.nix" ];
    missing-noctalia-override-uses-shared-defaults =
      let
        inherit (builtins.fromTOML noctaliaDefaults.config.xdg.configFile."noctalia/config.toml".text)
          include
          ;
      in
      noctaliaDefaults.config.my.home.noctalia.configFile == null
      &&
        include.files == [
          "default.toml"
          "${noctaliaDefaults.config.my.home.dotfilesDir}/modules/home/programs/noctalia/config.toml"
        ];
    override-folder-changes-only-selected-foot-setting =
      desktop.config.programs.foot.settings.main.font == "CaskaydiaCove Nerd Font:style=SemiBold:size=14"
      && directoryOverrides.config.programs.foot.settings.main.font == "monospace:size=12"
      &&
        directoryOverrides.config.programs.foot.settings.cursor
        == desktop.config.programs.foot.settings.cursor
      &&
        directoryOverrides.config.programs.foot.settings."colors-dark"
        == desktop.config.programs.foot.settings."colors-dark";
    ordinary-preset-overrides =
      !overrides.config.programs.kitty.enable
      && overrides.config.programs.foot.enable
      && overrides.config.programs.foot.settings.main.font == "monospace:size=12"
      && overrides.config.programs.foot.settings.cursor == desktop.config.programs.foot.settings.cursor
      && overrides.config.programs.fish.shellAbbrs.h-r == "home-fixture"
      && !overrides.config.my.home.media.enable;
    development-parent-disables-implicit-libraries =
      lib.all (name: !cppOff.config.my.home.dev.cpp.${name}.enable)
        [
          "dpp"
          "fmt"
          "ncurses"
          "qksh"
        ];
    explicit-library-without-parent =
      !explicitDpp.config.my.home.dev.cpp.enable && explicitDpp.config.my.home.dev.cpp.dpp.enable;
    shared-bundles-do-not-duplicate-features =
      !lib.any (p: builtins.elem p.outPath featurePaths) sharedPackages;
    shared-bundles-do-not-duplicate-system-packages =
      !lib.any (p: builtins.elem p.outPath systemPaths) sharedPackages;
    bundles-do-not-enable-features =
      !bundles.config.programs.fish.enable && !bundles.config.programs.kitty.enable;
  };
  failed = builtins.attrNames (lib.filterAttrs (_: pass: !pass) checks);
in
assert lib.assertMsg (failed == [ ]) "Home composition failed: ${lib.concatStringsSep ", " failed}";
checks
