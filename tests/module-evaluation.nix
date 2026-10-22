# Evaluate real hosts and Melal home overrides without activation.
{ self, inputs }:
let
  lib = inputs.nixpkgs.lib;
  base = self.nixosConfigurations.snowflake;
  home = self.homeConfigurations."melal@snowflake";
  rusty = self.homeConfigurations."melal@rusty";
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  hasPackage = package: packages: builtins.elem package.outPath (map (p: p.outPath) packages);
  packages = host: host.config.environment.systemPackages;
  toolchainRoots =
    instance:
    builtins.filter (
      path: !lib.hasSuffix "-fish-completions" (toString path)
    ) instance.config.home.extraDependencies;
  homeFor =
    host: extra:
    home.extendModules {
      specialArgs.osConfig = host.config;
      modules = [ extra ];
    };
  noFiles = prefix: files: !lib.any (lib.hasPrefix prefix) (builtins.attrNames files);
  passes = instance: lib.all (entry: entry.assertion) instance.config.assertions;
  packageModules = {
    cli = [
      ../modules/home/packages/cli.nix
      ../modules/home/packages/snowflake/cli.nix
    ];
    gui = [
      ../modules/home/packages/gui.nix
      ../modules/home/packages/snowflake/gui.nix
    ];
    io = [ ../modules/home/packages/io.nix ];
    databaseClients = [ ../modules/home/packages/database-clients.nix ];
    development = [
      ../modules/home/packages/development.nix
      ../modules/home/packages/snowflake/development.nix
    ];
  };
  homeOff = {
    disabledModules = lib.concatLists (builtins.attrValues packageModules);
    my.home = {
      desktop.enable = false;
      media.enable = false;
      development.enable = false;
      wm.niri.enable = false;
      noctalia.enable = lib.mkForce false;
      skwd.enable = false;
      openrgb.enable = lib.mkForce false;
      gpu-screen-recorder.enable = lib.mkForce false;
      keyboardTools.enable = false;
      bluetoothClient.enable = false;
      scripts.enable = false;
    };
    programs.kitty.enable = false;
    programs.foot.enable = false;
    programs.nh.enable = false;
    programs.obs-studio.enable = lib.mkForce false;
    services.easyeffects.enable = lib.mkForce false;
  };
  noUserFeatures = homeFor base homeOff;
  noNoctalia = homeFor base { my.home.noctalia.enable = lib.mkForce false; };
  noNiri = homeFor base { my.home.wm.niri.enable = false; };
  noGsr = homeFor base { my.home.gpu-screen-recorder.enable = lib.mkForce false; };
  noMedia = homeFor base { my.home.media.enable = false; };
  noEasyEffects = homeFor base { services.easyeffects.enable = lib.mkForce false; };
  # Package lists can be selected without importing Melal's common features.
  packageOnly = inputs.home-manager.lib.homeManagerConfiguration {
    inherit (home) pkgs;
    extraSpecialArgs = {
      inherit inputs unstable;
      hostname = "snowflake";
    };
    modules = [
      {
        nixpkgs.config.allowUnfree = true;
        home.username = "melal";
        home.homeDirectory = "/home/melal";
        home.stateVersion = "24.11";
      }
    ];
  };
  customMedia = homeFor base {
    services.mpd.dataDir = "/home/melal/.local/state/mpd-fixture";
  };
  hostOverrides = homeFor base {
    programs.foot.settings.main.font = "CaskaydiaCove Nerd Font:style=SemiBold:size=16";
    services.mpd.musicDirectory = "/home/melal/Music-fixture";
    programs.ncmpcpp.settings.visualizer_type = "spectrum";
    programs.fish = {
      preferAbbrs = false;
      shellAbbrs.qa = "logout";
      shellAliases.v = "nvim --clean";
    };
  };
  alternateNoctaliaConfig = toString (
    home.pkgs.writeText "rusty-noctalia-fixture.toml" ''
      [appearance]
      font_size = 18
    ''
  );
  rustyNoctalia = rusty.extendModules {
    modules = [
      {
        my.home.noctalia = {
          enable = true;
          configFile = alternateNoctaliaConfig;
        };
      }
    ];
  };
  rustyNoNoctalia = rustyNoctalia.extendModules {
    modules = [ { my.home.noctalia.enable = lib.mkForce false; } ];
  };
  noToolchains = lib.genAttrs (builtins.attrNames home.config.my.home.development.toolchains) (_: {
    enable = lib.mkForce false;
  });
  pythonOnly = homeFor base {
    my.home.development.toolchains = noToolchains // {
      py.enable = lib.mkForce true;
    };
  };
  pythonPackages = (import ../shells/package-groups.nix { inherit (pythonOnly) pkgs; }).packagesFor [
    "py"
  ];
  nixLdOff = base.extendModules { modules = [ { my.programs.nix-ld.enable = lib.mkForce false; } ]; };
  noWebcamHost = base.extendModules {
    modules = [ { my.hardware.androidWebcam.enable = lib.mkForce false; } ];
  };
  noMirrorHost = base.extendModules {
    modules = [ { my.programs.ipad-screen-mirror.enable = lib.mkForce false; } ];
  };
  noUxplay = homeFor noMirrorHost { };
  changedArch = base.extendModules { modules = [ { my.host.arch = lib.mkForce "x86-64-v3"; } ]; };
  changedArchHome = homeFor changedArch { };
  rawNoctalia =
    (homeFor base { my.home.noctalia.optimize_for_arch = false; }).config.my.home.noctalia.package;
  optimized = changedArch.pkgs.optimizeForArch { package = changedArch.pkgs.jq; };
  optimizedHome = changedArchHome.pkgs.optimizeForArch { package = changedArchHome.pkgs.jq; };
  overriddenArch = changedArch.pkgs.optimizeForArch {
    package = changedArch.pkgs.jq;
    arch = "x86-64";
  };
  mockPackage = attrs: { overrideAttrs = f: attrs // f attrs; };
  flagsKept = changedArch.pkgs.optimizeForArch {
    package = mockPackage { NIX_CFLAGS_COMPILE = "-fwrapv"; };
  };
  envFlagsKept = changedArch.pkgs.optimizeForArch {
    package = mockPackage {
      env = {
        NIX_CFLAGS_COMPILE = [
          "-pipe"
          "-fPIC"
        ];
        KEEP = "yes";
      };
    };
  };
  markers = {
    cli = [
      home.pkgs.tealdeer
      home.pkgs.btop-rocm
    ];
    gui = [
      home.pkgs.librewolf
      home.pkgs.prismlauncher
    ];
    io = [
      home.pkgs.jmtpfs
      home.pkgs.alsa-utils
    ];
    databaseClients = [
      unstable.lazysql
      home.pkgs.pgmodeler
    ];
    development = [
      home.pkgs.nil
      home.pkgs.typescript-language-server
      home.pkgs.bear
    ];
  };
  matrix = lib.concatMap (
    group:
    map
      (
        enabled:
        let
          # Melal selects only these lists, without enabling common features.
          instance = packageOnly.extendModules {
            modules = lib.optionals enabled packageModules.${group};
          };
        in
        {
          name = "home-${group}-${lib.boolToString enabled}";
          value = lib.all (p: hasPackage p instance.config.home.packages == enabled) markers.${group};
        }
      )
      [
        false
        true
      ]
  ) (builtins.attrNames markers);
  checks = builtins.listToAttrs matrix // {
    canonical-homes-and-aliases =
      lib.all
        (
          host:
          self.homeConfigurations."melal@${host}".config.home.username == "melal"
          &&
            self.homeConfigurations.${host}.activationPackage.drvPath
            == self.homeConfigurations."melal@${host}".activationPackage.drvPath
          && self.nixosConfigurations.${host}.config.networking.hostName == host
          && self.nixosConfigurations.${host}.config.system.stateVersion == "24.11"
          && self.homeConfigurations."melal@${host}".config.home.stateVersion == "24.11"
        )
        [
          "rusty"
          "snowflake"
        ];
    homes-pass-assertions =
      passes home && passes rusty && passes packageOnly && passes customMedia && passes rustyNoctalia;
    melal-account-and-outputs =
      builtins.attrNames self.homeConfigurations == [
        "melal@rusty"
        "melal@snowflake"
        "rusty"
        "snowflake"
      ]
      &&
        lib.all
          (
            host:
            let
              systemHost = self.nixosConfigurations.${host};
              account = systemHost.config.users.users.melal;
            in
            account.isNormalUser
            && account.description == "Melal"
            && account.home == "/home/melal"
            && account.shell.outPath == systemHost.pkgs.fish.outPath
            && systemHost.config.programs.fish.enable
            &&
              account.extraGroups == [
                "wheel"
                "networkmanager"
                "uinput"
                "input"
                "adbusers"
              ]
              ++ lib.optional systemHost.config.programs.gamemode.enable "gamemode"
            && self.homeConfigurations."melal@${host}".config.home.homeDirectory == "/home/melal"
          )
          [
            "rusty"
            "snowflake"
          ];
    package-lists-are-explicit =
      packageOnly.config.home.username == "melal"
      && packageOnly.config.home.homeDirectory == "/home/melal"
      && !(packageOnly.config.programs.git.settings ? user)
      && !packageOnly.config.programs.git.enable
      && !packageOnly.config.programs.fish.enable
      && !packageOnly.config.programs.kitty.enable
      && !lib.any (p: hasPackage p packageOnly.config.home.packages) (
        lib.concatLists (builtins.attrValues markers)
      );
    ordinary-host-preference-overrides =
      let
        cfg = hostOverrides.config;
      in
      cfg.programs.foot.settings.main.font == "CaskaydiaCove Nerd Font:style=SemiBold:size=16"
      && cfg.services.mpd.musicDirectory == "/home/melal/Music-fixture"
      && cfg.programs.ncmpcpp.mpdMusicDir == "/home/melal/Music-fixture"
      && lib.hasInfix ''music_directory     "/home/melal/Music-fixture"'' cfg.services.mpd.generatedConfig
      && cfg.programs.ncmpcpp.settings.visualizer_type == "spectrum"
      && !cfg.programs.fish.preferAbbrs
      && cfg.programs.fish.shellAbbrs.qa == "logout"
      && cfg.programs.fish.shellAliases.v == "nvim --clean"
      &&
        lib.all
          (
            instance:
            instance.config.programs.foot.settings.main.font == "CaskaydiaCove Nerd Font:style=SemiBold:size=14"
            && instance.config.services.mpd.musicDirectory == "/home/melal/Audio"
            && instance.config.programs.ncmpcpp.mpdMusicDir == "/home/melal/Audio"
            && instance.config.programs.ncmpcpp.settings.visualizer_type == "ellipse"
            && instance.config.programs.fish.preferAbbrs
            && instance.config.programs.fish.shellAbbrs.qa == "exit"
            && instance.config.programs.fish.shellAliases.v == "nvim"
          )
          [
            home
            rusty
          ]
      && cfg.programs.foot.settings."colors-dark" == home.config.programs.foot.settings."colors-dark"
      && cfg.programs.foot.settings.cursor == home.config.programs.foot.settings.cursor
      && cfg.programs.foot.settings.key-bindings == home.config.programs.foot.settings.key-bindings
      && cfg.programs.foot.server.enable
      &&
        builtins.removeAttrs cfg.programs.ncmpcpp.settings [ "visualizer_type" ]
        == builtins.removeAttrs home.config.programs.ncmpcpp.settings [ "visualizer_type" ]
      && cfg.programs.fish.shellAbbrs.h-r == home.config.programs.fish.shellAbbrs.h-r
      && cfg.programs.fish.shellAliases.vi == home.config.programs.fish.shellAliases.vi;
    host-specific-noctalia =
      !rusty.config.my.home.noctalia.enable
      && home.config.my.home.noctalia.enable
      && rustyNoctalia.config.my.home.noctalia.enable
      && rustyNoctalia.config.my.home.noctalia.configFile == alternateNoctaliaConfig
      && home.config.my.home.noctalia.configFile != alternateNoctaliaConfig
      &&
        toString rustyNoctalia.config.xdg.configFile."noctalia/config.toml".source
        == toString (rustyNoctalia.config.lib.file.mkOutOfStoreSymlink alternateNoctaliaConfig)
      && hasPackage rustyNoctalia.config.my.home.noctalia.package rustyNoctalia.config.home.packages
      && rustyNoctalia.config.xdg.configFile ? "niri/noctalia.kdl"
      && lib.hasInfix ''spawn-at-startup "noctalia"'' (
        builtins.readFile rustyNoctalia.config.xdg.configFile."niri/noctalia.kdl".source
      )
      && noFiles "noctalia/" rusty.config.xdg.configFile
      && !(rusty.config.xdg.configFile ? "niri/noctalia.kdl")
      && noFiles "noctalia/" rustyNoNoctalia.config.xdg.configFile
      && !(rustyNoNoctalia.config.xdg.configFile ? "niri/noctalia.kdl")
      && !(rustyNoNoctalia.config.home.activation ? noctaliaTheme)
      && !(rustyNoNoctalia.config.home.activation ? noctaliaPlugins)
      && !hasPackage rustyNoctalia.config.my.home.noctalia.package rustyNoNoctalia.config.home.packages;
    private-media-resources =
      lib.all
        (
          instance:
          let
            cfg = instance.config;
            socket = "${cfg.services.mpd.dataDir}/socket";
            fifo = "${cfg.services.mpd.dataDir}/visualizer.fifo";
          in
          cfg.services.mpd.network.startWhenNeeded
          && cfg.systemd.user.sockets.mpd.Socket.ListenStream == [ socket ]
          && cfg.systemd.user.sockets.mpd.Socket.SocketMode == "0600"
          && cfg.systemd.user.sockets.mpd.Socket.DirectoryMode == "0700"
          && cfg.services.mpd.network.listenAddress == socket
          && cfg.home.sessionVariables.MPD_HOST == socket
          && cfg.programs.ncmpcpp.settings.mpd_host == socket
          && lib.hasInfix ''bind_to_address     "${socket}"'' cfg.services.mpd.generatedConfig
          && cfg.programs.ncmpcpp.settings.visualizer_data_source == fifo
          && lib.hasInfix fifo cfg.services.mpd.generatedConfig
          && !lib.hasInfix "/tmp/mpd" cfg.services.mpd.generatedConfig
        )
        [
          home
          rusty
          customMedia
          hostOverrides
        ]
      &&
        home.config.services.mpd.network.listenAddress
        != customMedia.config.services.mpd.network.listenAddress;
    kitty-runtime-expansion =
      home.config.programs.kitty.settings.listen_on == "unix:$XDG_RUNTIME_DIR/kitty"
      && customMedia.config.programs.kitty.settings.listen_on == "unix:$XDG_RUNTIME_DIR/kitty";
    terminal-disable-removes-config =
      noFiles "kitty/" noUserFeatures.config.xdg.configFile
      && noFiles "foot/" noUserFeatures.config.xdg.configFile
      && !(noUserFeatures.config.home.file ? ".config/kitty/themes")
      && !(noUserFeatures.config.systemd.user.services ? foot);
    home-desktop-disabled =
      !noUserFeatures.config.gtk.enable
      && !noUserFeatures.config.qt.enable
      && noUserFeatures.config.home.pointerCursor == null;
    home-media-disabled =
      !noMedia.config.services.mpd.enable
      && !noMedia.config.services.playerctld.enable
      && !noMedia.config.programs.ncmpcpp.enable
      && !(noMedia.config.home.file ? ".config/ncmpcpp/thumbnail")
      && !(noMedia.config.systemd.user.sockets ? mpd)
      && !hasPackage home.pkgs.mpc noMedia.config.home.packages
      && !hasPackage home.pkgs.mpd-mpris noMedia.config.home.packages
      && !lib.hasInfix "playerctl" noMedia.config.xdg.configFile."niri/applications.kdl".text;
    home-development-disabled =
      !(noUserFeatures.config.home.sessionVariables ? CODELLDB_PATH)
      && !(noUserFeatures.config.home.file ? ".editorconfig")
      && toolchainRoots noUserFeatures == [ ];
    nh-disabled-has-no-cleanup-timer = !(noUserFeatures.config.systemd.user.timers ? nh-clean);
    scripts-disabled =
      !(noUserFeatures.config.home.file ? ".local/bin/assets-setup")
      && !(noUserFeatures.config.home.file ? ".local/bin/theme-switch");
    noctalia-disabled =
      noFiles "noctalia/" noNoctalia.config.xdg.configFile
      && !(noNoctalia.config.xdg.configFile ? "niri/noctalia.kdl")
      && !hasPackage home.config.my.home.noctalia.package noNoctalia.config.home.packages;
    noctalia-without-niri =
      noNiri.config.my.home.noctalia.enable
      && noFiles "niri/" noNiri.config.xdg.configFile
      && !(noNiri.config.home.file ? ".config/niri/config.kdl");
    host-capabilities-independent =
      base.config.services.pipewire.enable
      && base.config.programs.dconf.enable
      && base.config.services.upower.enable
      && base.config.services.power-profiles-daemon.enable
      && base.config.networking.networkmanager.enable
      && base.config.hardware.bluetooth.enable
      && base.config.services.hardware.openrgb.enable
      && base.config.programs.niri.enable
      && base.config.programs.gpu-screen-recorder.enable
      && base.config.security.wrappers.gsr-kms-server.capabilities == "cap_sys_admin+ep"
      && base.config.hardware.keyboard.qmk.enable
      && !base.config.programs.direnv.enable
      && !(base.config.systemd.user.services ? skwd-walld)
      && !(base.config.systemd.user.services ? noctalia);
    user-startup-owners =
      home.config.services.easyeffects.enable
      && home.config.systemd.user.services.easyeffects.Install.WantedBy == [ "graphical-session.target" ]
      && !lib.hasInfix "easyeffects" home.config.home.file.".local/bin/niri-autostart".text
      && home.config.systemd.user.services.skwd-walld.Install.WantedBy == [ "graphical-session.target" ]
      && !(home.config.systemd.user.services ? noctalia)
      && !(home.config.systemd.user.services ? uxplay)
      && !lib.hasInfix "gsr-ui" noGsr.config.home.file.".local/bin/niri-autostart".text
      && !(noGsr.config.home.file ? ".local/bin/mpv-mix")
      && !(noEasyEffects.config.systemd.user.services ? easyeffects)
      && !(noUserFeatures.config.systemd.user.services ? skwd-walld)
      && !(noUserFeatures.config.systemd.user.services ? openrgb-client);
    uxplay-host-policy =
      base.config.services.avahi.enable
      && base.config.services.avahi.publish.enable
      && base.config.services.avahi.publish.userServices
      && base.config.services.avahi.openFirewall
      && base.config.networking.firewall.enable
      && base.config.systemd.services.avahi-daemon.wantedBy == [ ]
      && base.config.systemd.sockets.avahi-daemon.wantedBy == [ ]
      && base.config.my.programs.ipad-screen-mirror.port == 7000
      && base.config.my.programs.ipad-screen-mirror.package.outPath == unstable.uxplay.outPath
      && base.config.my.programs.ipad-screen-mirror.receiverName == null
      &&
        lib.all
          (
            port:
            builtins.elem port base.config.networking.firewall.allowedTCPPorts
            && builtins.elem port base.config.networking.firewall.allowedUDPPorts
          )
          [
            7000
            7001
            7002
          ]
      && lib.any (p: lib.getName p == "uxplay") (packages base)
      && !lib.any (p: lib.getName p == "uxplay") home.config.home.packages
      && !(base.config.systemd.services ? uxplay)
      && !(base.config.systemd.user.services ? uxplay)
      && passes noUxplay
      && !noMirrorHost.config.services.avahi.enable
      && !lib.any (p: lib.getName p == "uxplay") (packages noMirrorHost)
      && !lib.any
        (
          port:
          builtins.elem port noMirrorHost.config.networking.firewall.allowedTCPPorts
          || builtins.elem port noMirrorHost.config.networking.firewall.allowedUDPPorts
        )
        [
          7000
          7001
          7002
        ];
    manual-system-policies =
      !base.config.virtualisation.oci-containers.containers.mssql.autoStart
      && base.config.systemd.services.nix-serve.wantedBy == [ ]
      && !base.config.my.hardware.androidWebcam.autoStart
      && !(builtins.elem "v4l2loopback" base.config.boot.kernelModules)
      &&
        base.config.virtualisation.oci-containers.containers.mssql.volumes
        == [ "mssql-data:/var/opt/mssql" ]
      && base.config.services.nix-serve.secretKeyFile == "/var/lib/nix-cache/cache.sec";
    android-webcam-system-owned =
      let
        tools = with base.pkgs; [
          scrcpy
          v4l-utils
          android-tools
        ];
      in
      base.config.my.hardware.androidWebcam.enable
      && lib.all (p: hasPackage p (packages base)) tools
      # android-tools remains an independent selection in the shared I/O list.
      && !(home.config.my.home ? androidWebcam)
      && hasPackage base.config.boot.kernelPackages.v4l2loopback base.config.boot.extraModulePackages
      && !lib.any (p: hasPackage p (packages noWebcamHost)) tools
      && !hasPackage noWebcamHost.config.boot.kernelPackages.v4l2loopback noWebcamHost.config.boot.extraModulePackages;
    single-toolchain-selection =
      map toString (toolchainRoots pythonOnly) == map (p: p.outPath) pythonPackages;
    nix-ld-independent =
      nixLdOff.config.programs.nix-ld.enable == false
      && hasPackage home.pkgs.nil (homeFor nixLdOff { }).config.home.packages;
    filesystem-tools-system-owned =
      base.config.boot.supportedFilesystems.ntfs && hasPackage base.pkgs.ntfs3g (packages base);
    fonts-remain-system-owned = hasPackage base.pkgs.sf-pro base.config.fonts.packages;
    host-architecture-propagates =
      lib.hasInfix "-march=x86-64-v3 -O3" optimized.NIX_CFLAGS_COMPILE
      && lib.hasInfix "-march=x86-64-v3 -O3" optimizedHome.NIX_CFLAGS_COMPILE
      && lib.hasInfix "-march=x86-64-v3 -O3" changedArchHome.config.my.home.noctalia.package.NIX_CFLAGS_COMPILE;
    package-architecture-override = lib.hasInfix "-march=x86-64 -O3" overriddenArch.NIX_CFLAGS_COMPILE;
    optimized-package-build-controls = !optimized.allowSubstitutes && optimized.preferLocalBuild;
    existing-compiler-flags-preserved =
      flagsKept.NIX_CFLAGS_COMPILE == "-fwrapv -march=x86-64-v3 -O3"
      && envFlagsKept.env.NIX_CFLAGS_COMPILE == "-pipe -fPIC -march=x86-64-v3 -O3"
      && envFlagsKept.env.KEEP == "yes"
      && !(envFlagsKept ? NIX_CFLAGS_COMPILE);
    disabled-optimization-returns-original =
      rawNoctalia.drvPath == inputs.noctalia.packages.x86_64-linux.default.drvPath;
    personal-applications-owned-by-home =
      lib.all
        (
          host:
          let
            systemHost = self.nixosConfigurations.${host};
            user = self.homeConfigurations."melal@${host}";
            userPackages = user.config.home.packages;
            systemNames = map lib.getName (packages systemHost);
          in
          !lib.any (name: builtins.elem name systemNames) [
            "git"
            "kitty"
            "foot"
            "yazi"
            "lazygit"
            "ncmpcpp"
            "fastfetch"
            "starship"
            "librewolf"
            "neovim"
            "easyeffects"
            "noctalia"
            "obs-studio"
            "gpu-screen-recorder-ui"
          ]
          && hasPackage user.config.programs.kitty.package userPackages
          && hasPackage user.config.programs.foot.package userPackages
          && hasPackage user.pkgs.librewolf userPackages
          && hasPackage user.pkgs.nil userPackages
          && user.config.home.sessionVariables.BROWSER == "helium"
          && lib.hasInfix "@${host}" user.config.programs.fish.shellAbbrs.h-r
        )
        [
          "rusty"
          "snowflake"
        ];
    package-provenance-and-user-edits =
      hasPackage unstable.codex home.config.home.packages
      &&
        hasPackage self.homeConfigurations."melal@rusty".pkgs.codex
          self.homeConfigurations."melal@rusty".config.home.packages
      && hasPackage unstable.opencode home.config.home.packages
      && hasPackage home.pkgs.pspp home.config.home.packages
      && !hasPackage unstable.opencode self.homeConfigurations."melal@rusty".config.home.packages
      && home.config.my.home.noctalia.plugins.pomodoro.widgets.widget.widget-glyph-main == "clock"
      && home.config.my.home.noctalia.plugins.pomodoro.widgets.widget.widget-glyph-work == "coffee";
    obs-plugins-independent-of-receiver =
      map (p: p.outPath) noUxplay.config.programs.obs-studio.plugins
      == map (p: p.outPath) home.config.programs.obs-studio.plugins;
    obs-wrapper-preserved =
      hasPackage home.pkgs.obs-studio-plugins.obs-vaapi home.config.programs.obs-studio.plugins
      && lib.any (
        p:
        lib.getName p == "obs-gstreamer"
        && lib.any (arg: lib.hasInfix "gst-plugins-good" arg) p.obsWrapperArguments
        && lib.any (arg: lib.hasInfix "gst-libav" arg) p.obsWrapperArguments
      ) home.config.programs.obs-studio.plugins;
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg (
  failed == [ ]
) "Migration evaluation checks failed: ${lib.concatStringsSep ", " failed}";
checks
