# Melal’s NixOS & Home Manager Configuration

This repository configures one user, Melal, across Rusty and Snowflake using
NixOS and standalone Home Manager.

## Ownership and composition

NixOS owns hardware, the Melal account and login shell, permissions, networking,
firewalls, privileged wrappers and shared services. All active Home Manager
configuration, personal preferences, package lists, scripts and assets live in
`modules/home/`.

```text
modules/home/
├── default.nix                 # Melal’s identity and common defaults
├── hosts/
│   ├── noctalia.nix            # Shared personal Noctalia/plugin defaults
│   ├── rusty/
│   │   ├── default.nix         # Package choices and host overrides
│   │   └── noctalia-config.toml
│   └── snowflake/
│       ├── default.nix
│       └── noctalia-config.toml
├── packages/                   # Unconditional common and host package lists
├── programs/                   # App configuration and assets
├── shell/
├── scripts/
├── dev/
└── lib/
```

The flake discovers `hosts/<host>/default.nix`, builds that NixOS configuration,
and combines `modules/home/default.nix` with `modules/home/hosts/<host>/default.nix` for Melal.
Every machine must have both entrypoints. Canonical homes are `melal@rusty` and
`melal@snowflake`; the `rusty` and `snowflake` aliases remain available. There is
no user discovery or user-membership metadata. The explicit account module is
`modules/nixos/system/melal.nix`.

`pkgs/`, `overlays/` and project `shells/` remain shared flake infrastructure.
Home Manager reads `osConfig` for genuine host capabilities and CPU architecture.
The lock file and NixOS/Home Manager state versions (`24.11`) are unchanged.

`modules/home/` is the single active Home Manager tree; there is no top-level
`home/` directory. Shared assets remain unchanged at their existing paths.
The distinct old Niri `programs/wm/niri/config.kdl`, Noctalia
`programs/noctalia/noctalia-config.toml`, and former user TOML are retained for
live and rollback references. New generations use Niri's `session.kdl` and the
selected host's Noctalia TOML. Keep the old targets until their references have
been migrated and checked.
See [MIGRATION-RESULTS.md](MIGRATION-RESULTS.md) for validation and staged activation.

## Adding a machine

1. Create `hosts/<host>/default.nix` and its hardware configuration, importing
   `../../modules/nixos`. Select host capabilities there; the shared system
   modules declare Melal’s existing account and grants.
2. Create `modules/home/hosts/<host>/default.nix`. Import the package lists wanted on that
   machine and add its application choices, settings and data files.
3. Track new files before using a Git flake. During uncommitted work,
   `path:$PWD` includes new files without staging them.

## Common defaults and host overrides

Common personal choices use `lib.mkDefault`. A host can use an ordinary assignment
to disable a common application or change a preference. Import order does not
override conflicting Nix definitions; host overrides do not need `mkForce` when
replacing a common default.

For example, a host can select a different Foot font without changing the other
machine or losing its remaining terminal settings:

```nix
programs.foot.settings.main.font = "CaskaydiaCove Nerd Font:style=SemiBold:size=16";
```

Both real hosts retain size 14 and enable Noctalia. Each host selects its editable
TOML through `my.home.noctalia.configFile`, under
`modules/home/hosts/<hostname>/noctalia-config.toml`. Rusty starts with Snowflake's
appearance settings and omits Discord Voice from its plugins and bar. Common
feature defaults and host choices remain separate from NixOS hardware prerequisites.

## Personal packages and features

Each host explicitly imports its chosen lists from:

```text
modules/home/packages/{cli,gui,io,database-clients}.nix
modules/home/packages/rusty/{cli,gui}.nix
modules/home/packages/snowflake/{cli,gui}.nix
```

Every package-only file is unconditional. Remove an import from one host to
remove that list’s contribution on that machine. There is no package-group enable
option or default package bundle. Database clients do not require a local server.
Development environments are selected by language under `my.home.dev`.

| Home Manager option | Responsibility |
| --- | --- |
| `my.home.dev.<language>.enable` | SDK/toolchain, bundled language tools and editor integration |
| `my.home.desktop.enable` | GTK/Qt, cursor and dconf preferences |
| `my.home.media.enable` | MPD, ncmpcpp, playerctld and playback helpers |
| `programs.kitty/foot/ghostty.enable` | Terminal installation, configuration and files |
| `programs.direnv.enable` and `programs.direnv.nix-direnv.enable` | User direnv integration |
| `my.home.scripts.enable` | Dependency-wrapped helpers and repository preferences |

Git, Fastfetch, Yazi, Lazygit, Nh and Starship use their upstream program options.
`my.home.keyboardTools` and `my.home.bluetoothClient` select personal clients;
they do not grant host-device access. Fish helpers supply their own dependencies,
including when the general CLI list is omitted. The `h-r` abbreviation selects
`melal@<host>`.

NixOS retains shared fonts, an administrative package baseline, Rusty’s network
and power diagnostics, MSSQL/Podman, nix-serve, Steam/GameMode, nix-ld,
PipeWire/WirePlumber, Niri/Ly, portals, keyring, PAM and hardware permissions.
Their existing storage, secrets, grants and lifecycle policies are preserved.

### Applications with host prerequisites

| Feature | NixOS | Home Manager and startup |
| --- | --- | --- |
| UXPlay | `my.programs.ipad-screen-mirror.enable`: manual `uxplay` launcher, system Avahi publishing, mDNS and receiver firewall | No separate HM option; receiver startup remains manual |
| EasyEffects | PipeWire and `programs.dconf.enable` | `services.easyeffects.enable`: graphical-session unit; replaces the Niri launch |
| OBS | Existing audio/graphics/device support | `programs.obs-studio.enable`: same plugins; `my.home.obs.gstreamer.enable` selects the GStreamer wrapper |
| GPU Screen Recorder | `my.programs.gpu-screen-recorder.enable`: recorder and KMS capability wrapper | `my.home.gpu-screen-recorder.enable`, optional `.autostart`: frontends and Niri launch |
| OpenRGB | Hardware server and permissions | `my.home.openrgb.enable`: tray-client unit |
| Noctalia | Explicit NetworkManager, Bluetooth, UPower and power-profiles-daemon backends | `my.home.noctalia.enable`: shell/config/plugins; starts through Niri |
| Skwd | Graphical-session prerequisites | `my.home.skwd.enable`: graphical-session daemon plus its own Niri wallpaper-restoration fragment |
| Android webcam | `my.hardware.androidWebcam.enable`: kernel module, modprobe settings, scrcpy, v4l-utils and android-tools; Snowflake keeps `autoStart = false` | No separate HM option |
| QMK | Udev rules and account grants | Selected clients; no extra permissions |

Applications contribute Niri login commands through
`my.home.wm.niri.startupCommands`, a text option that merges contributions with
newlines. Niri supplies the script header and assembles those commands into
`~/.local/bin/niri-autostart`. Skwd owns wallpaper restoration; GPU Screen Recorder
owns its optional UI launch. Their `mkBefore` / `mkAfter` definitions preserve that
order. Skwd's daemon uses its graphical-session service, while the recorder UI
starts at Niri login when both its feature and `autostart` are enabled. Disabling
Niri omits the generated startup script.

Snowflake keeps its automatic graphical applications; Rusty does not inherit
Snowflake's shell, recording or audio-effects selections. EasyEffects now receives
HM's service supervision and graphical-session stop behavior. Noctalia still has
no enabled systemd unit. `mpd-mpris` remains installed without an automatic launcher.

### Private media resources

MPD keeps its existing data directory and socket activation. It listens only on
`$XDG_DATA_HOME/mpd/socket` (normally `~/.local/share/mpd/socket`), with a user-only
socket mode. The pinned HM module's additional TCP listener is explicitly removed.
`MPD_HOST`, ncmpcpp and the notification helper use that same absolute socket.
The visualizer FIFO is `$XDG_DATA_HOME/mpd/visualizer.fifo`, shared with ncmpcpp.
Existing MPD state and music stay in place. External TCP clients need to use the
Unix socket; the unused upstream port option still reads 6600 but no TCP listener
is configured. Kitty expands `$XDG_RUNTIME_DIR` in its socket path and adds its
instance PID. Process checks and terminal reload signals are scoped to the user.

### Independent nix-ld compatibility

`my.programs.nix-ld.enable` defaults to false and is explicitly enabled on both
hosts. It preserves the existing compatibility libraries (X11, Qt, C++ runtime,
OpenGL, ICU and zlib). It is independent of every development/package-group
switch, so development tools and externally built binary compatibility can be
selected separately. NixOS's native `programs.nix-ld.enable` also remains usable.

| Feature | Global default | Snowflake | Rusty |
| --- | --- | --- | --- |
| `my.home.noctalia.enable` (HM) | false | true | true |
| `my.services.nix-serve.enable` | false | true, interface `enp4s0` | false |
| `my.hardware.disablePcieWakeup.enable` | false | true | false |
| `my.programs.ipad-screen-mirror.enable` | false | true | false |

Noctalia uses its existing flake package; its host backends are selected independently in NixOS.
`my.home.noctalia.optimize_for_arch` defaults to true and appends
`-march=<arch> -O3` while retaining existing compiler flags. Snowflake sets
`my.packages.optimization.arch = "znver3"` once; Rusty's 11th-generation Intel Core
i5 G7 uses `"tigerlake"`. Other hosts should set a matching compiler architecture.
The fallback is the host platform's compiler
architecture, or `x86-64`. Set `optimize_for_arch = false` to use the original
package without an override. Noctalia uses the shared `pkgs.optimizeForArch`
helper described below.

Home Manager's `my.home.noctalia.enable` defaults to false and is selected by Melal
on both Snowflake and Rusty through `modules/home/hosts/noctalia.nix`.
It links the main TOML directly into this checkout, like Niri, so editing
`~/.config/noctalia/config.toml` edits
`modules/home/hosts/<hostname>/noctalia-config.toml` immediately. It also manages
the separate theme and wallpaper files, `black-mo.json`, and a generated,
read-only `~/.config/noctalia/plugins.toml`.
Each WM attaches its integration when both it and Noctalia are enabled; the Niri
fragment supplies startup and the existing `Mod+R/X/N/V` panel bindings. Enabling
Noctalia alone does not enable a WM. The unused Spicetify import was removed:
there is no active Spicetify configuration or locked input.

### Noctalia plugins

Each `my.home.noctalia.plugins.<name>.enable` defaults to false. Both hosts import
the shared personal preset in `modules/home/hosts/noctalia.nix`, enabling Bongocat,
Nix Search, Pomodoro and Timer with matching settings. Snowflake also enables
Discord Voice; Rusty explicitly disables it and omits its `bar` widget.
The parent `my.home.noctalia.enable` gates their files, packages and activation.

| Plugin option | Noctalia plugin ID | Packages selected when enabled |
| --- | --- | --- |
| `discord-voice.enable` | `raycursive/discord-voice` | Python newer than 3.10 and Discord |
| `bongocat.enable` | `noctalia/bongocat` | evtest |
| `nix-search.enable` | `knyrps/nix-search` | nix-search-tv, fzf and xdg-utils |
| `pomodoro.enable` | `thepunkoff/pomodoro` | FFmpeg, including ffplay |
| `timer.enable` | `noctalia/timer` | None |

For example, in a user's host override:

```nix
my.home.noctalia.plugins = {
  discord-voice.enable = true;
  bongocat.enable = true;
  nix-search.enable = true;
  pomodoro.enable = true;
  timer.enable = true;
};
```

Apply Home Manager after changing an option. It regenerates `plugins.toml`
with the enabled IDs, plugin settings and widget definitions.
The module uses Nixpkgs' standard `pkgs.formats.toml` generator to serialize
these Nix attribute sets as TOML.
The main TOML imports this file; keep those generated keys out of the main file
because Noctalia gives an including file's own values precedence.
Each plugin has `settings` and `widgets` attribute sets. The shared module
supplies plugin IDs, dependencies, widget types and dependency executable paths.
Common Pomodoro durations and Bongocat styling live in the shared personal preset;
Snowflake keeps its Discord preferences in its own Home Manager configuration.
Bar layout lives under `[bar.default]` in the editable main
`modules/home/hosts/<hostname>/noctalia-config.toml`, linked as
`~/.config/noctalia/config.toml`. Edit its `start`, `center` and `end` lists
directly; layout changes need no Home Manager switch. These lists are not
generated or filtered by Nix, so remove a plugin's widget name there when
disabling that plugin. Saved GUI bar overrides still take precedence over
the editable TOML until cleared manually in `settings.toml`.
The shared Bongocat preset selects the Corne keyboard through
`my.home.noctalia.plugins.bongocat.widgets.cat.input_devices`. A host can override
that list for a different keyboard and grant the user input-device access.
The existing user belongs to the `input` group.

Dependencies are installed through Home Manager, including when the shared
CLI/GUI lists are not imported. Disabling a plugin removes its own package
additions; packages selected by other features or lists remain available.
The standalone nix-search-tv, fzf and Discord selections in the shared package
lists remain independent.

Noctalia downloads missing enabled plugins on startup. If it is already running
during activation, Home Manager reloads its configuration and refreshes the
official/community sources that have missing enabled plugin files. Network
access is needed for those downloads. Disabled plugins may remain cached on disk.
Plugin updates still use Noctalia's runtime updater.

Before reloading, activation reads saved GUI overrides from
`~/.local/state/noctalia/settings.toml` and warns about keys that disagree with
the generated configuration. Warnings are yellow on a terminal and respect
`NO_COLOR`. It also honors `NOCTALIA_STATE_HOME` and `XDG_STATE_HOME`.
Equivalent Discord executable symlinks are treated as the same setting.
The helper never rewrites or deletes the saved settings.
GUI overrides continue to take precedence until the conflicting entries are
cleared manually. Other GUI preferences remain available.

After applying Home Manager, inspect these settings anytime with:

```bash
noctalia-config-status
```

The command reports plugins enabled in the applied Home Manager generation,
missing downloaded `plugin.toml` files and saved GUI overrides that conflict
with managed plugin settings or widget values. It uses the same state
directory resolution and yellow warnings as activation. It only reads files;
it does not reload Noctalia, download plugins or modify saved settings.
Apply Home Manager again to include subsequent edits from this checkout in
the report. The missing-file check covers each plugin's `plugin.toml` manifest;
complete plugin health requires a separate check.

### Hardware and device services

GPU configuration uses `my.hardware.gpu.<vendor>.enable` as its sole source of
truth. The former `my.host.gpus` inventory only duplicated those switches in
assertions and has been removed. Snowflake retains AMD; Rusty retains Intel and
NVIDIA. The PCIe workaround preserves the original udev rule and disables wake
events from PCIe port bridges, which can prevent devices behind them from
waking the system.

Battery settings live in `modules/nixos/hardware/battery.nix`. Rusty selects
`my.hardware.battery.present = true` and
`my.hardware.battery.optimization.enable = true`, enabling power-profiles-daemon
for Noctalia's power controls while preserving UPower and deep sleep. Auto-cpufreq
is disabled; its battery and charger settings remain configured for future use.
Optimization requires a present battery. Snowflake leaves
both options at their false defaults. Niri continues to use battery presence to
include brightness controls; no display inventory is needed. Monitor settings
remain in Niri's optional `monitor.kdl`.

UXPlay still requires the **system Avahi daemon running** and the **NixOS
firewall configuration**. The NixOS `my.programs.ipad-screen-mirror` module owns
the receiver launcher, its arguments, Avahi and firewall rules.
`services.avahi.enable = true` configures the shared daemon;
cleared service/socket `wantedBy` lists keep it out of boot targets. Neither
setting proves the daemon is currently running. Existing D-Bus activation policy
is unchanged. An administrator starts discovery when needed; the user starts the
receiver separately:

```bash
sudo systemctl start avahi-daemon.service
uxplay
```

The launcher checks system Avahi readiness and exits clearly when it is missing.
It never starts privileged services. There is no UXPlay user unit, `sudo` inside
activation, or dependency pretending that a user unit can order a system unit.
`publish.userServices` allows advertisements through the shared daemon; it does
not isolate Avahi by user. UXPlay itself runs under the normal user account.

`my.programs.ipad-screen-mirror.port` defaults to 7000 and opens TCP/UDP
7000–7002. The launcher uses the same option and passes `-p 7000` by default;
the module configures Avahi publishing, mDNS and the receiver firewall rules.
The user confirmed no external receiver settings need preservation. Additional
arguments remain usable, but overriding ports requires corresponding host firewall
changes. See the
[pinned UXPlay documentation](https://github.com/FDH2/UxPlay/blob/v1.73.7/README.md).
For simultaneous receivers, allocate disjoint port triples and distinct receiver
names/device identities deliberately; the current setup has one configured user
and does not implement multiple-instance allocation.

### Optimizing other packages from source

`lib/optimize-for-arch.nix` is exposed as `pkgs.optimizeForArch` by the shared
overlay. Set the architecture once in `hosts/<name>/default.nix`:

```nix
my.packages.optimization.arch = "znver3";
```

`modules/nixos/packages/optimization.nix` binds `pkgs.optimizeForArch` to that
option, and Home Manager inherits the same default through `osConfig`. Apply it
to any source package whose C/C++ build honors `NIX_CFLAGS_COMPILE`, without
repeating the architecture:

```nix
{ pkgs, unstable, ... }:
{
  environment.systemPackages = [
    (pkgs.optimizeForArch {
      package = pkgs.jq;
    })
    (pkgs.optimizeForArch {
      package = unstable.btop;
      optimize_for_arch = true; # Default; false returns the original package unchanged.
    })
  ];
}
```

An optional `arch = "x86-64"` argument overrides the host default for one call.
Hosts without an explicit `my.packages.optimization.arch` use the host platform's compiler
architecture, falling back to `x86-64`. Standalone use of the pure helper outside
a host configuration still takes an explicit `arch` argument. The Noctalia-only
architecture option has been removed; Noctalia uses `my.packages.optimization.arch` too.

The helper appends `-march=<arch> -O3`, preserving existing flags whether the
package stores them in `NIX_CFLAGS_COMPILE` or `env.NIX_CFLAGS_COMPILE`. It sets
`allowSubstitutes = false` and `preferLocalBuild = true` on the selected package
so a missing output is built locally from its source derivation. Dependencies
still use the normal binary caches, and an existing optimized store output is
reused. These are Nix's [per-derivation build controls](https://nix.dev/manual/nix/stable/language/advanced-attributes.html);
the global `always-allow-substitutes` setting can override `allowSubstitutes`.

Pass the derivation that compiles the source (often an application's
`-unwrapped` package when the public package is only a wrapper). Adding compiler
flags cannot turn a binary-only,
`-bin`, or AppImage package into a source build. These flags optimize C/C++ code;
Rust and Go code require their own compiler flags. Set `arch` to match the CPU
where the package will run. This helper changes only the package explicitly
passed to it; it does not rebuild or retune the entire package set.

## Getting Started

To build and apply a system configuration:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

To build and apply a Home Manager configuration (standalone):

```bash
home-manager switch --flake .#melal@<hostname>
```

The `.#<hostname>` Home Manager alias also selects Melal's home on that machine.

To build the custom package:

```bash
nix build .#easydotnet
```

## Development environments

Each language has a Home Manager option under `my.home.dev`. Its parent option
installs the SDK/compiler, language tools, formatter/debugger where selected,
and language server together. There is no separate LSP switch. Libraries and
frameworks live under their language:

```nix
# modules/home/hosts/<host>/default.nix
my.home.dev = {
  cpp = {
    enable = true;
    dpp.enable = true;
    audio.enable = true;
  };
  csharp = {
    enable = true;
    avalonia.enable = true;
  };
  python = {
    enable = true;
    science.enable = true;
  };
};
```

Available parent groups are `cpp`, `csharp`, `python`, `javascript`, `lua`, `go`,
`rust`, `java`, `nix`, `shell`, `json`, `xml` and `text`. C++ also offers `fmt`,
`ncurses` and `qksh`; Java offers `javafx`. Every selection defaults off and each
host explicitly chooses its groups. EditorConfig and the existing tree-sitter
utility accompany enabled parent groups; the C++ group owns its debugger path.

Nested selections work independently of the parent option. For example,
`cpp.dpp.enable = true` supplies DPP and its required compiler/build dependencies;
`cpp.enable = true` adds the full personal C++ setup, including its LSP and debugger.
Similarly, Avalonia alone supplies its .NET SDK and native libraries; the C#
parent adds Roslyn and the general C# tools. Python science can also be selected
without the general Python editor setup.

Project shells remain independent of Home Manager selections:

```bash
nix develop .#cpp
nix develop .#dpp
nix develop .#avalonia
```

All existing shell names, package definitions and hooks are preserved. The DPP
shell explicitly selects GCC, Make, CMake, pkg-config, DPP, opusfile, liboggz and
fmt; it does not add clangd or GDB. Existing general C++ and .NET shells retain
their own tooling. Entering a shell does not enable a Home Manager option.

The Home Manager modules reuse `shells/package-groups.nix` for SDKs and libraries,
adding their editor tools in `modules/home/dev/`. Selected shell outputs are
collected once, deduplicated and rooted through `home.extraDependencies`, including
headers and development outputs. Installing those packages globally does not
execute a shell's hooks or export its `LD_LIBRARY_PATH` / `DOTNET_ROOT` throughout
the session. Those environments apply inside `nix develop`.

Rusty enables C++, C#, Java, Python and Lua, plus Nix/shell/JSON/XML/text tooling.
Its former standalone Yarn and Watchman selections are removed as requested.
Snowflake also enables JavaScript, Go and Rust, Avalonia and scientific Python.
Both keep their existing C++ library selections. The added Rusty SDKs and the
Java SDK on both hosts are deliberate user choices; Go and Rust now bundle their
language servers on Snowflake.

Stable/unstable package choices and relative priorities are retained.
Snowflake keeps plain Python ahead of the science environment through its existing
Noctalia dependency; use `nix develop .#py-science` for the scientific environment.
The global Quickshell command comes from the plain `qksh` development environment.
Niri no longer installs `qmlgolsp` or the separate `quickshell-niri` package.
FFmpeg command precedence is unchanged. The priority helper is
`modules/home/lib/after-home-packages.nix`.

For separately pinned projects, keep project flakes and use `.envrc` with
`use flake`, followed by `direnv allow`.

## On-demand LAN cache

Snowflake can serve its existing Nix store to Rusty over Ethernet on port 5000.
It enables `my.services.nix-serve` and sets its `interface = "enp4s0"` in the host
configuration. Other hosts can opt in with their Ethernet interface; `port`
defaults to 5000 and `keyName` defaults to `<hostname>-1`.
The service is installed but has no boot target: rebuilds and reboots do not start
it automatically. Rusty's persistent cache settings are unchanged.

Apply the Snowflake configuration once:

```bash
sudo nixos-rebuild switch --flake .#snowflake
```

Activation generates `/var/lib/nix-cache/cache.sec` once and derives
`/var/lib/nix-cache/cache.pub` from it. The private key stays outside Git and
`/nix/store`; preserve it across reinstalls to keep the same cache identity.

On Snowflake, start serving and display the public key:

```bash
sudo systemctl start nix-serve
sudo cat /var/lib/nix-cache/cache.pub
```

On Rusty, pull the same configuration and pass the entire public-key line to
this rebuild command. Replace the address if Snowflake's DHCP address changes;
using its LAN IP does not require `.local` hostname discovery.

```bash
git pull
curl http://192.168.10.87:5000/nix-cache-info
sudo nixos-rebuild switch --flake .#rusty \
  --option extra-substituters 'http://192.168.10.87:5000?priority=10' \
  --option extra-trusted-public-keys 'snowflake-1:REPLACE_WITH_PUBLIC_KEY' \
  --option fallback true
```

These options apply to this invocation and preserve the existing internet caches.
Matching packages already on Rusty are reused; missing packages are fetched from
Snowflake first, then internet caches, or built locally. Snowflake does not build
or download packages in response to cache requests.

For a separate configuration, follow the [revision-matching instructions](NIX-DOWNLOAD-RECOVERY.md#matching-nixpkgs-revisions-for-a-lan-cache) to align its nixpkgs lock entry with Snowflake while keeping its own `flake.nix` input URL.

Stop serving on Snowflake when finished:

```bash
sudo systemctl stop nix-serve
```

## Validation

For failed source downloads, see the [step-by-step download recovery guide](NIX-DOWNLOAD-RECOVERY.md), including parallel byte ranges and importing verified files into the Nix store.

```bash
nix fmt
nix flake check
```

The flake checks formatting, dead code, Nix linting, every development shell's Bash hook syntax, Niri with each home's generated browser/Noctalia fragments, asset bootstrap behavior, theme switching, generated user-script syntax, profile command priorities, module feature combinations, and each canonical Home Manager activation package. Home Manager checks build the generation without activating it. NixOS configurations are evaluated without switching the running system.

The `module-evaluation` check covers canonical homes and aliases, package/feature
disablement, independent host capabilities, manual service policies, per-host overrides,
UXPlay dependencies/ports, private media paths, package provenance and overrides,
and development output rooting. It evaluates configuration without compiling
the selected applications. Run those assertions directly with:

```bash
nix eval --json --impure --expr '
  let f = builtins.getFlake ("path:" + toString ./.);
  in import ./tests/module-evaluation.nix { self = f; inputs = f.inputs; }
'
```

Some upstream inputs fetch a toolchain manifest during evaluation, so a full check may be needed before `nix flake check --no-build` works on a fresh store.

## Fresh install

After running `nixos-rebuild switch` and `home-manager switch`, run:

```bash
assets-setup
```

This non-interactive, idempotent script:
1. Clones/updates the assets repo to `~/.local/share/assets` and creates symlinks:
   - `~/.local/share/assets/wallpapers` → `~/Pictures/Wallpapers`
   - `~/.local/share/assets/pfp` → `~/Pictures/Pfp`
   - `~/.local/share/assets/videos` → `~/Videos/Wallpapers`
2. Clones/updates dedicated standalone configuration repos:
   - `git@github.com:Melal1/quickshell.git` → `~/.config/quickshell`
   - `git@github.com:Melal1/neovim.git` (branch `java`) → `~/.config/nvim`
3. Seeds the default terminal theme (`vague`) and, for configured applications, Niri's initial colors and Noctalia's `black-mo` theme/palette. Only absent links are seeded, preserving selected themes.
4. Seeds the theme indirection links (only if absent — never clobbers the current theme):
   - `~/.local/state/theme/wallpaper` → `~/.local/share/assets/wallpapers/default.jpg`
   - `~/.local/state/theme/video` → `~/.local/share/assets/videos/rain2k.webm`
   - `~/.local/state/theme/media` → `~/.local/share/assets/wallpapers/default.jpg`
5. Applies the current media link through `skwd-helm` if `skwd-walld` is running.

When replacing an existing asset destination, setup moves it to `.bk`, `.bk.1`, and so on, preserving earlier backups. A failed backup stops setup before the original destination is replaced.

Niri automatically configures outputs until `nwg-displays` creates `~/.config/niri/monitor.kdl`. The include is optional, and existing monitor configurations remain editable. Niri also starts and supervises `xwayland-satellite` on demand.

The selected browser is Helium on both hosts; LibreWolf remains available. Home Manager generates Niri's browser binding and environment from `home.sessionVariables.BROWSER`; `Mod+B` expands `$BROWSER` at launch.

## Themes & wallpapers

Terminal themes (Kitty `~/.config/kitty/current.conf`, Ghostty `~/.config/ghostty/theme`), Niri `~/.config/niri/default.kdl`, Noctalia `~/.config/noctalia/default.toml` and `~/.config/noctalia/palettes/default.json`, and the active wallpaper state are **mutable symlinks**. Home Manager manages the stable application configs and fallback files, and never declares these active links. Activation and `assets-setup` only seed missing links; `theme-switch <name>` atomically replaces each available link without a rebuild.

Themes are directories in `~/.local/share/assets/themes/<name>/` with these optional slots (files or symlinks):

| Slot | Contents / active destination |
| --- | --- |
| `kitty` | Kitty colors → `~/.config/kitty/current.conf` |
| `ghostty` | Ghostty settings → `~/.config/ghostty/theme` |
| `niri` | Top-level KDL settings → `~/.config/niri/default.kdl` |
| `noctalia` | TOML `[theme]` settings → `~/.config/noctalia/default.toml` |
| `noctalia-palette` | Palette JSON → `~/.config/noctalia/palettes/default.json` |
| `wallpaper` or `wallpapers/` | One image, or a directory of image choices → `~/.local/state/theme/wallpaper` |
| `video` | Video → `~/.local/state/theme/video` |

Missing slots leave the corresponding current selection intact. Niri and
Noctalia slots are used only when those applications are configured. For a
custom Noctalia theme, use `source = "custom"` and
`custom_palette = "default"` in its `[theme]` section. The initial theme file
retains the existing `black-mo` settings through that stable palette name.
The main config sets `[include].autoload = false` to make it the sole entry
point and includes `default.toml`, `wallpapers/config.toml` and `plugins.toml`.
It never changes during a theme switch. Noctalia supports `~` in wallpaper paths.
Noctalia's wallpaper service is disabled with `[wallpaper].enabled = false`;
`skwd-wall` handles rendering. Default, last and monitor wallpaper paths point
to `~/.local/state/theme/wallpaper`, with `fill_mode = "stretch"` retained.
Home Manager creates no link to Noctalia's bundled wallpaper image. On a fresh
setup the state link starts at `~/Pictures/Wallpapers/black.jpg`; an existing wallpaper
selection is preserved. A theme with both image and video slots updates the
image link for Noctalia and uses video for skwd-wall.

Noctalia's [configuration includes](https://docs.noctalia.dev/noctalia/configuration/)
support this split. Its GUI overrides in `~/.local/state/noctalia/settings.toml`
take precedence over config files; an existing override of a theme or wallpaper
setting must be cleared there if it should follow these files.

```bash
theme-switch --list            # list available themes
theme-switch vague             # switch; multi-wallpaper themes use default.*
theme-switch vague river       # pick a wallpaper by (sub)name
theme-switch vague --random    # pick a random wallpaper from the theme
```

`skwd-walld` provides unified image and video wallpaper rendering in Niri. `theme-switch` applies the selected media with `skwd-helm`, and Skwd's Niri startup fragment restores it at login. Terminal reload signals are sent to Kitty (SIGUSR1) and Ghostty (SIGUSR2). Niri watches its included theme file; Noctalia receives `noctalia msg config-reload` after a theme or palette change.
