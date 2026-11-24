# Configuration options

This reference covers every `my.*` option declared by this repository. It also names the upstream switches used to control its applications. Edit [`hosts/<host>/home.nix`](hosts/snowflake/home.nix) for **Home** options and [`hosts/<host>/default.nix`](hosts/snowflake/default.nix) for **NixOS** options. For features that connect the two, see [Shared](#shared).

**Default** means the value declared by the module. **Enabled on** and **Current selection** include the core, presets, and host files. “Both” means Rusty and Snowflake. A host can override a `lib.mkDefault` with an ordinary assignment. To change an ordinary host assignment, edit it at its source, or use a higher-priority override in another module.

## Home

### Desktop, media, and scripts

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.home.dotfilesDir` | String, `${config.home.homeDirectory}/.dotfiles/nixos` | Both use `/home/melal/.dotfiles/nixos` for editable files and script paths. |
| `my.home.desktop.enable` | Boolean, `false` | Both. The desktop preset selects GTK, Qt, dconf preferences, and the pointer theme. |
| `my.home.media.enable` | Boolean, `false` | Both. The desktop preset selects MPD, ncmpcpp, playerctld, and playback helpers. Niri adds media bindings when enabled. |
| `my.home.skwd.enable` | Boolean, `false` | Both. The desktop preset selects the wallpaper suite and graphical-session daemon. Niri additionally restores the active wallpaper at login. |
| `my.home.skwd.modelPackage` | Package, `skwd-wall` input’s `skwd-lens-model` | Both use the default semantic model. |
| `my.home.skwd.extraPackages` | List of packages, `[ ]` | Both use the empty list. Entries are installed and added to the daemon’s search path. |
| `my.home.scripts.enable` | Boolean, `false` | Core enables it on both. Installs the personal scripts and tmux config. The brightness helper also requires the desktop option. |
| `my.home.scripts.vicinae.enable` | Boolean, `false` | Neither. Adds the Vicinae GitHub menu when scripts are enabled and a username is set. |
| `my.home.scripts.githubUsername` | String matching `[A-Za-z0-9-]+` or `null`, default `null` | Core selects `melal1` for the GitHub menu. |
| `my.home.scripts.assets.url` | String or `null`, default `null` | Core selects `git@github.com:Melal1/assets.git` for `assets-setup`. |
| `my.home.scripts.assets.httpsUrl` | String, `""` | Core selects `https://github.com/Melal1/assets.git` as the fallback URL. |
| `my.home.scripts.assets.quickshellUrl` | String or `null`, default `null` | Core selects `git@github.com:Melal1/quickshell.git`. Set to `null` to skip syncing that checkout. |
| `my.home.scripts.assets.neovimUrl` | String or `null`, default `null` | Core selects `git@github.com:Melal1/neovim.git`. Set to `null` to skip syncing that checkout. |
| `my.home.scripts.assets.neovimBranch` | String, `""` | Core selects the `unstable` branch. |

See the [core defaults](modules/home/core.nix), [desktop preset](modules/home/presets/desktop.nix), and [script module](modules/home/scripts/default.nix).

### Development

Every switch here is a Boolean with a declared default of `false`. The development preset makes the four C++ add-ons follow `my.home.dev.cpp.enable` by default. Each add-on can be selected independently. The Avalonia, JavaFX, and scientific Python options also select their own package groups independently of the parent’s editor tools. RStudio is gated by the R option. [Development preset](modules/home/presets/development.nix) · [Toolchain selection](modules/home/dev/default.nix)

| Option | Enabled on | What it selects |
| --- | --- | --- |
| `my.home.dev.cpp.enable` | Both | C++ toolchain, debugger, Bear, and CMake language server. |
| `my.home.dev.cpp.dpp.enable` | Both | DPP and its C++ build dependencies. |
| `my.home.dev.cpp.fmt.enable` | Both | The fmt C++ library and build dependencies. |
| `my.home.dev.cpp.ncurses.enable` | Both | ncurses and build dependencies. |
| `my.home.dev.cpp.qksh.enable` | Both | Quickshell and Qt build dependencies. |
| `my.home.dev.csharp.enable` | Both | .NET SDK and Roslyn language server. |
| `my.home.dev.csharp.avalonia.enable` | Snowflake | .NET SDK and Avalonia native dependencies. |
| `my.home.dev.go.enable` | Snowflake | Go toolchain and gopls. |
| `my.home.dev.java.enable` | Both | JDK 21 and Java language server. |
| `my.home.dev.java.javafx.enable` | Neither | JavaFX SDK and native dependencies. |
| `my.home.dev.javascript.enable` | Snowflake | JavaScript/TypeScript runtime, web language servers, and formatting tools. |
| `my.home.dev.json.enable` | Both | JSON language server. |
| `my.home.dev.lua.enable` | Both | Lua runtimes and editor tools. |
| `my.home.dev.nix.enable` | Both | nil language server and nixpkgs-fmt editor tool. The repository formatter is configured separately in `treefmt.nix`. |
| `my.home.dev.python.enable` | Both | Python, uv, and Python editor tools. |
| `my.home.dev.python.science.enable` | Snowflake | Python environment with the scientific package bundle. |
| `my.home.dev.r.enable` | Both | R with nortest, ggplot2, and dplyr. |
| `my.home.dev.r.ide` | Both | Adds RStudio with the same libraries when R is enabled. |
| `my.home.dev.rust.enable` | Snowflake | Rust toolchain and rust-analyzer. |
| `my.home.dev.shell.enable` | Both | ShellCheck, shfmt, and Bash language server. |
| `my.home.dev.text.enable` | Both | Harper writing checker. |
| `my.home.dev.xml.enable` | Both | libxml2 tools. |

### Upstream Home Manager controls

| Options used directly | How this configuration uses them |
| --- | --- |
| `programs.home-manager.enable`, `programs.fish.enable`, `programs.git.enable`, `programs.fastfetch.enable`, `programs.yazi.enable`, `programs.lazygit.enable`, `programs.nh.enable`, `programs.starship.enable`, `programs.zoxide.enable`, `programs.direnv.enable`, `programs.direnv.nix-direnv.enable` | Core enables each by default. Fish also supplies shell tools, including tmux. |
| `programs.neovim.enable`, `programs.neovim.package` | Both hosts enable Neovim and select the pinned nightly package in `hosts/<host>/home-packages.nix`. Set `programs.neovim.enable = false;` to use the Nano fallback. |
| `programs.neovim.withRuby`, `programs.neovim.withPython3` | Both hosts default the Ruby provider to `false` and the Python 3 provider to `true`. |
| `programs.neovim.sideloadInitLua` | Both hosts enable this so the existing Neovim checkout supplies `~/.config/nvim/init.lua`. |
| `programs.kitty.enable`, `programs.foot.enable`, `programs.ghostty.enable` | The desktop preset enables Kitty and Foot. Ghostty is independently selectable. Niri emits launch bindings for the enabled Kitty and Foot terminals. |
| `home.sessionVariables.EDITOR`, `home.sessionVariables.BROWSER` | Core defaults the editor to `nvim` when Neovim is enabled and installs and selects `nano` otherwise. An explicit `EDITOR` overrides the default. The desktop preset selects `helium` and Niri uses the browser setting for its bindings. |
| `services.mpd.enable`, `programs.ncmpcpp.enable`, `services.playerctld.enable` | The media option enables all three. Override `services.mpd.musicDirectory` to change the default `~/Audio`. |
| `programs.rea.enable`, `programs.rea.package` | Snowflake imports the REA Home Manager module and selects its package. The program is currently disabled. |

The CLI, desktop application, I/O, database-client, and container-client bundles are selected by importing their files. [Package modules](modules/home/packages)

## NixOS

### System features

The switches in this table are Booleans with a declared default of `false`.

| Option | Enabled on | What it selects |
| --- | --- | --- |
| `my.hardware.androidWebcam.enable` | Snowflake | scrcpy, ADB, v4l-utils, and the v4l2loopback device. |
| `my.hardware.battery.optimization.enable` | Rusty | Enables UPower, power-profiles-daemon, and deep sleep. Requires the battery to be marked present. |
| `my.hardware.disablePcieWakeup.enable` | Snowflake | Disables wake events from PCIe port bridges. |
| `my.hardware.gpu.intel.enable` | Rusty | Enables Intel graphics and media acceleration. |
| `my.hardware.gpu.nvidia.enable` | Rusty | Enables the proprietary NVIDIA driver and settings. |
| `my.hardware.performance.enable` | Snowflake | Applies the AMD performance governor and platform tuning. |
| `my.hardware.touchpad.enable` | Rusty | Enables libinput touchpad support. |
| `my.packages.fonts.shared.enable` | Both | Installs the system font collection and fontconfig preferences. Override families with `fonts.fontconfig.defaultFonts` on the host. |
| `my.programs.ipad-screen-mirror.enable` | Snowflake | Installs the manual UXPlay receiver and configures Avahi and the firewall. Start Avahi before launching the receiver. |
| `my.programs.nix-ld.enable` | Both | Enables loader and library support for externally built Linux binaries. |
| `my.programs.steam.enable` | Snowflake | Enables Steam, GameMode, Proton and gaming tools. Snowflake selects `programs.gamescope.enable` separately. |
| `my.services.nix-serve.enable` | Snowflake | Configures a manually started, signed binary cache. |
| `my.virtualisation.docker.enable` | Neither | Enables the Docker daemon. |
| `my.virtualisation.docker.autoStart` | Neither | With Docker enabled, allows its normal boot activation. |
| `my.virtualisation.mssql.enable` | Both | Configures a manually started SQL Server container. Requires the Podman switch under [Shared](#shared). |

### System settings

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.hardware.androidWebcam.autoStart` | Boolean, `true` | Snowflake sets `false` and keeps the loopback module available for manual loading. Rusty has the webcam feature off. |
| `my.programs.ipad-screen-mirror.package` | Package, `unstable.uxplay` | Snowflake uses the default receiver. |
| `my.programs.ipad-screen-mirror.port` | Port, `7000` | Opens this port and the next two for TCP and UDP. The highest valid starting port is `65533`. |
| `my.programs.ipad-screen-mirror.receiverName` | String or `null`, default `null` | Set a name to pass it to UXPlay. Both hosts leave it unset. |
| `my.services.nix-serve.interface` | String, required when enabled | Snowflake selects `"enp4s0"` for the firewall rule. |
| `my.services.nix-serve.port` | Port, `5000` | Snowflake serves the cache on the default port. |
| `my.services.nix-serve.keyName` | String, `"${config.networking.hostName}-1"` | Snowflake uses `"snowflake-1"` when generating its cache signing key. |

## Shared

The flake passes each NixOS host’s evaluated configuration to its Home Manager configuration as `osConfig`. **Forced** means that enabling the host feature automatically includes the base Home integration. **Optional** means the user can select the Home feature separately. Some optional clients still require a specific host capability. [Host composition](flake/hosts.nix)

### GPU Screen Recorder · optional Home UI

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.programs.gpu-screen-recorder.enable` | Boolean, `false` | Snowflake. Installs the recorder and privileged KMS wrapper. The backend works by itself. |
| `my.home.gpu-screen-recorder-ui.enable` | Boolean, `false` | Snowflake explicitly assigns the host switch to this option. Enables the GTK, overlay, and notification frontends. With a NixOS host, the UI requires `programs.gpu-screen-recorder.enable`. |
| `my.home.gpu-screen-recorder-ui.autostart` | Boolean, `false` | Snowflake defaults to `true`. Adds the overlay launch at Niri login when both the UI and Home Niri are enabled. |

To keep recording on Snowflake without its UI, replace the existing `enable = osConfig.my.programs.gpu-screen-recorder.enable;` in its Home file with `enable = false;`. To keep the UI for manual use, set only `autostart = false;`. With the UI and mpv available, Home also supplies `mpv-mix`. [Snowflake Home](hosts/snowflake/home.nix) · [Recorder UI module](modules/home/programs/gpu-screen-recorder-ui.nix)

### WinApps · forced base integration, optional launcher

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.virtualisation.podman.enable` | Boolean, `false` | Both. Provides the container engine. Podman alone leaves WinApps optional. |
| `my.virtualisation.winapps.enable` | Boolean, `false` | Snowflake. Requires Podman and the `crun` runtime. Enables KVM access and automatically supplies WinApps, Podman Compose, the VM definition and OEM files to the paired Home. |
| `my.home.winapps.launcher.enable` | Boolean, `false` | Snowflake defaults to `true`. Set to `false` to omit the tray launcher while keeping WinApps. |
| `my.home.winapps.windowsVersion` | String, `"11"` | Windows edition selector. Snowflake uses the default. |
| `my.home.winapps.ramSize` | String, `"8G"` | Snowflake assigns `"12G"` to the VM. |
| `my.home.winapps.cpuCores` | Positive integer, `4` | Snowflake assigns `8` virtual CPUs. |
| `my.home.winapps.diskSize` | String, `"128G"` | Initial capacity of the persistent VM disk. Snowflake uses the default. |

There is no `my.home.winapps.enable` switch. Turning the host option off removes the managed integration on the next Home Manager switch. VM startup remains manual. A standalone Home without `osConfig` skips WinApps. [Host module](modules/nixos/system/winapps.nix) · [Home module](modules/home/programs/winapps.nix) · [VM setup](README.md#winapps)

### Niri and battery · optional Home session, automatic brightness bindings

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.desktop.niri.enable` | Boolean, `false` | Both. Enables the system Niri session, display manager, and portals. |
| `my.home.wm.niri.enable` | Boolean, `false` | The desktop preset enables it on both. The user can disable it independently. When a host is supplied, Home checks that its Niri session is enabled. |
| `my.home.wm.niri.startupCommands` | Lines of shell text, `""` | Home merges contributions into `niri-autostart`. Both restore Skwd wallpaper. Snowflake also starts the recorder overlay. |
| `my.hardware.battery.present` | Boolean, `false` | Rusty. With Home Niri enabled, battery presence automatically adds brightness keys and brightnessctl to the Niri configuration. |

### Noctalia and CPU targeting · optional shell, inherited build target

| Option | Type and default | Current selection and effect |
| --- | --- | --- |
| `my.home.noctalia.enable` | Boolean, `false` | Both hosts enable it. When Home Niri is also enabled, its Noctalia fragment starts the shell and adds keybindings. |
| `my.packages.optimization.arch` | String matching `[A-Za-z0-9_+-]+`, host platform’s GCC architecture or `"x86-64"` | Rusty uses `"tigerlake"`, Snowflake `"znver3"`. The host and paired Home pass this target to `pkgs.optimizeForArch`. |
| `my.home.noctalia.optimize_for_arch` | Boolean, `true` | Both use the host target for the default shell package. Set to `false` for the portable build. |
| `my.home.noctalia.package` | Package, Noctalia input’s default package via `pkgs.optimizeForArch` | Both use the default. A custom package replaces the computed one. |
| `my.home.noctalia.configFile` | String or `null`, host TOML path when present, otherwise `null` | Both include `hosts/<host>/noctalia-config.toml` from the checkout after the active theme. Set to `null` for the theme and upstream defaults. |

NetworkManager, Bluetooth, UPower, and power-profiles-daemon are host choices. Enabling Noctalia selects the shell and its plugins without enabling those services. [Noctalia module](modules/home/programs/noctalia/default.nix)

### Hardware clients and media · optional clients

| Option | Type and default | Current selection and relationship |
| --- | --- | --- |
| `my.hardware.rgb.enable` | Boolean, `false` | Snowflake enables the system OpenRGB server on port `6742`. The server can run alone. |
| `my.home.openrgb.enable` | Boolean, `false` | Snowflake enables the tray client. It requires the host OpenRGB service when a host is supplied and reads its configured port. |
| `my.hardware.bluetooth.enable` | Boolean, `false` | Both enable Bluetooth device support. |
| `my.home.bluetoothClient.enable` | Boolean, `false` | Both select bluetui independently. The package choice neither grants access nor enables host Bluetooth. |
| `my.hardware.vial-qmk.enable` | Boolean, `false` | Both enable QMK keyboard support and VIA udev rules. |
| `my.home.keyboardTools.enable` | Boolean, `false` | Both select QMK, Vial, and VIA clients independently of the host’s device rules. |
| `my.hardware.gpu.amd.enable` | Boolean, `false` | Snowflake enables AMD graphics, LACT, and overdrive. When OBS is also enabled, its Home module automatically adds the VA-API plugin. |
| `programs.obs-studio.enable` (Home Manager) | Boolean, `false` | Snowflake enables OBS. The AMD, screen-recorder, and UXPlay host switches do not enable OBS. |
| `my.home.obs.gstreamer.enable` | Boolean, `false` | Snowflake adds the optional UDP/RTP and software-decoding plugin to enabled OBS. |
| `services.easyeffects.enable` (Home Manager) | Boolean, `false` | Snowflake enables EasyEffects. When a host is supplied, the Home module requires both NixOS `programs.dconf.enable` and `services.pipewire.enable`. Those prerequisites can be enabled without the client. |
