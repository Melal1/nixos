# Evaluation-only regressions: exercise actual host and Home Manager modules
# without building or activating a system generation.
{ self, inputs }:
let
  lib = inputs.nixpkgs.lib;
  base = self.nixosConfigurations.snowflake;
  home = self.homeConfigurations.snowflake;
  groups = [
    "cli"
    "gui"
    "io"
    "development"
    "fonts"
  ];
  off = lib.genAttrs groups (_: {
    shared = false;
    host = false;
  });

  withGroups =
    selection:
    base.extendModules {
      modules = [
        {
          my.packages = lib.mapAttrs (
            _: scopes: lib.mapAttrs (_: enabled: { enable = lib.mkForce enabled; }) scopes
          ) (lib.recursiveUpdate off selection);
        }
      ];
    };

  hasPackage = package: packages: builtins.elem package.outPath (map (p: p.outPath) packages);
  packages = host: host.config.environment.systemPackages;
  homeFor =
    host: extra:
    home.extendModules {
      specialArgs.osConfig = host.config;
      modules = [ extra ];
    };

  # These markers belong to the real lists. The I/O matrix disables NTFS
  # support so ntfs3g measures only the host package group. Fonts currently
  # have no host-only list.
  markers = {
    cli = {
      shared = base.pkgs.jq;
      host = base.pkgs.btop-rocm;
    };
    gui = {
      shared = base.pkgs.librewolf;
      host = base.pkgs.prismlauncher;
    };
    io = {
      shared = base.pkgs.jmtpfs;
      host = base.pkgs.ntfs3g;
    };
    development = {
      shared = base.pkgs.nil;
      host = base.pkgs.typescript-language-server;
    };
    fonts = {
      shared = base.pkgs.sf-pro;
    };
  };
  matrix = lib.concatMap (
    group:
    lib.concatMap
      (
        shared:
        map
          (
            host:
            let
              groupInstance = withGroups { ${group} = { inherit shared host; }; };
              instance =
                if group == "io" then
                  groupInstance.extendModules {
                    modules = [
                      {
                        boot.supportedFilesystems = {
                          ntfs = lib.mkForce false;
                          ntfs-3g = lib.mkForce false;
                        };
                      }
                    ];
                  }
                else
                  groupInstance;
              selected = if group == "fonts" then instance.config.fonts.packages else packages instance;
            in
            {
              name = "${group}-shared-${lib.boolToString shared}-host-${lib.boolToString host}";
              value =
                hasPackage markers.${group}.shared selected == shared
                && (!(markers.${group} ? host) || hasPackage markers.${group}.host selected == host);
            }
          )
          [
            false
            true
          ]
      )
      [
        false
        true
      ]
  ) groups;

  noDevelopment = withGroups { };
  nixLdOff = base.extendModules {
    modules = [ { my.programs.nix-ld.enable = lib.mkForce false; } ];
  };
  noToolchains = lib.genAttrs (builtins.attrNames base.config.my.development.toolchains) (_: {
    enable = lib.mkForce false;
  });
  pythonOnly = (withGroups { development.host = true; }).extendModules {
    modules = [
      {
        my.development.toolchains = noToolchains // {
          py.enable = lib.mkForce true;
        };
      }
    ];
  };
  pythonPackages = (import ../shells/package-groups.nix { inherit (pythonOnly) pkgs; }).packagesFor [
    "py"
  ];

  noUserFeatures = homeFor base {
    my.home.desktop.enable = lib.mkForce false;
    my.home.media.enable = lib.mkForce false;
    my.home.development.enable = lib.mkForce false;
    programs.nh.enable = lib.mkForce false;
  };
  noNoctaliaHost = base.extendModules {
    modules = [ { my.programs.noctalia.enable = lib.mkForce false; } ];
  };
  noNoctaliaHome = homeFor noNoctaliaHost { };
  noNiriHome = homeFor base { my.home.wm.niri.enable = lib.mkForce false; };
  changedArch = base.extendModules {
    modules = [ { my.host.arch = lib.mkForce "x86-64-v3"; } ];
  };
  changedArchHome = homeFor changedArch { };
  rawNoctalia =
    (base.extendModules {
      modules = [ { my.programs.noctalia.optimize_for_arch = false; } ];
    }).config.programs.noctalia.package;
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
  noFeatureFiles =
    prefix: files: !lib.any (name: lib.hasPrefix prefix name) (builtins.attrNames files);
  allDefaultsOff = lib.all (
    group:
    !base.options.my.packages.${group}.shared.enable.default
    && !base.options.my.packages.${group}.host.enable.default
  ) groups;

  checks = builtins.listToAttrs matrix // {
    package-groups-default-off = allDefaultsOff;
    io-disabled-retains-filesystem-tools =
      noDevelopment.config.boot.supportedFilesystems.ntfs
      && hasPackage noDevelopment.pkgs.ntfs3g (packages noDevelopment);
    nix-ld-without-development =
      noDevelopment.config.programs.nix-ld.enable
      && !hasPackage base.pkgs.nil (packages noDevelopment)
      && noDevelopment.config.system.extraDependencies == [ ];
    development-without-nix-ld =
      !nixLdOff.config.programs.nix-ld.enable && hasPackage nixLdOff.pkgs.nil (packages nixLdOff);
    single-toolchain-selection =
      map toString pythonOnly.config.system.extraDependencies == map (p: p.outPath) pythonPackages;
    editor-tools-follow-development =
      !hasPackage base.pkgs.typescript-language-server (packages noDevelopment)
      && !hasPackage base.pkgs.prettier (packages noDevelopment)
      && !hasPackage base.pkgs.bear (packages noDevelopment);
    gui-io-integration =
      let
        instance = withGroups {
          io.shared = true;
          gui.host = true;
        };
        headless = withGroups { io.shared = true; };
      in
      hasPackage instance.pkgs.pavucontrol (packages instance)
      && !hasPackage headless.pkgs.pavucontrol (packages headless);
    home-desktop-disabled =
      !noUserFeatures.config.gtk.enable
      && !noUserFeatures.config.qt.enable
      && noUserFeatures.config.home.pointerCursor == null;
    home-media-disabled =
      !noUserFeatures.config.services.mpd.enable
      && !noUserFeatures.config.services.playerctld.enable
      && !noUserFeatures.config.programs.ncmpcpp.enable
      && !(noUserFeatures.config.home.file ? ".config/ncmpcpp/thumbnail")
      && !hasPackage noUserFeatures.pkgs.mpc noUserFeatures.config.home.packages
      && !hasPackage noUserFeatures.pkgs.mpd-mpris noUserFeatures.config.home.packages;
    home-development-disabled =
      !(noUserFeatures.config.home.sessionVariables ? CODELLDB_PATH)
      && !(noUserFeatures.config.home.file ? ".editorconfig");
    nh-disabled-has-no-cleanup-timer = !(noUserFeatures.config.systemd.user.timers ? nh-clean);
    noctalia-disabled =
      !noNoctaliaHost.config.programs.noctalia.enable
      && !noNoctaliaHost.config.programs.noctalia.recommendedServices.enable
      && !noNoctaliaHome.config.my.home.noctalia.enable
      && noFeatureFiles "noctalia/" noNoctaliaHome.config.xdg.configFile
      && !(noNoctaliaHome.config.xdg.configFile ? "niri/noctalia.kdl")
      && !hasPackage noNoctaliaHost.pkgs.evtest (packages noNoctaliaHost);
    noctalia-without-niri =
      noNiriHome.config.my.home.noctalia.enable
      && noFeatureFiles "niri/" noNiriHome.config.xdg.configFile
      && !(noNiriHome.config.home.file ? ".config/niri/config.kdl");
    host-architecture-propagates =
      lib.hasInfix "-march=x86-64-v3 -O3" optimized.NIX_CFLAGS_COMPILE
      && lib.hasInfix "-march=x86-64-v3 -O3" optimizedHome.NIX_CFLAGS_COMPILE
      && lib.hasInfix "-march=x86-64-v3 -O3" changedArch.config.programs.noctalia.package.NIX_CFLAGS_COMPILE;
    package-architecture-override = lib.hasInfix "-march=x86-64 -O3" overriddenArch.NIX_CFLAGS_COMPILE;
    optimized-package-build-controls = !optimized.allowSubstitutes && optimized.preferLocalBuild;
    existing-compiler-flags-preserved =
      flagsKept.NIX_CFLAGS_COMPILE == "-fwrapv -march=x86-64-v3 -O3"
      && envFlagsKept.env.NIX_CFLAGS_COMPILE == "-pipe -fPIC -march=x86-64-v3 -O3"
      && envFlagsKept.env.KEEP == "yes"
      && !(envFlagsKept ? NIX_CFLAGS_COMPILE);
    disabled-optimization-returns-original =
      rawNoctalia.drvPath
      == inputs.noctalia.packages.${base.pkgs.stdenv.hostPlatform.system}.default.drvPath;
    applications-owned-by-home-manager =
      lib.all
        (
          name:
          let
            systemHost = self.nixosConfigurations.${name};
            user = self.homeConfigurations.${name};
            systemNames = map lib.getName (packages systemHost);
            userPackages = user.config.home.packages;
          in
          !lib.any (p: builtins.elem p systemNames) [
            "git"
            "kitty"
            "foot"
            "ghostty"
            "yazi"
            "lazygit"
            "ncmpcpp"
            "fastfetch"
            "starship"
          ]
          && hasPackage user.config.programs.kitty.package userPackages
          && hasPackage user.config.programs.foot.package userPackages
          && hasPackage user.config.programs.yazi.finalPackage userPackages
          && hasPackage user.config.programs.ncmpcpp.package userPackages
          && user.config.programs.git.package != null
          && hasPackage user.config.programs.git.package userPackages
          && !hasPackage user.config.programs.git.package (packages systemHost)
        )
        [
          "snowflake"
          "rusty"
        ];
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg (
  failed == [ ]
) "Modularity evaluation checks failed: ${lib.concatStringsSep ", " failed}";
checks
