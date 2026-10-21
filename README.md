# NixOS & Home Manager Configuration

This repository contains my declarative NixOS and standalone Home Manager configuration.

## Directory Structure

- `flake.nix`: Flake-parts entry point. Declares inputs, supported systems, packages, development shells and treefmt integration.
- `flake/`: Flake-parts modules for output assembly.
  - `hosts.nix`: Auto-discovers hosts and users; `mkHost`/`mkHome` build NixOS and standalone Home Manager configurations, including the single-user hostname aliases.
  - `checks.nix`: Validation checks and canonical Home Manager activation builds. Keeps the existing `formatting` check name; the treefmt module supplies the formatter.
- `hosts/`: One directory per machine, named after the flake output.
  - `hosts/snowflake/`: Desktop machine. `hardware-configuration.nix` + a thin list of `my.*` toggles.
  - `hosts/rusty/`: Laptop machine.
  - `hosts/<name>/meta.nix`: Per-host metadata (`users`) read by the flake.
- `modules/`: Shared modules, all host-agnostic.
  - `modules/nixos/`: System modules. Features are gated behind `my.*` enable options.
  - `modules/home/`: Home Manager modules (programs, shell, dev, scripts).
  - `modules/nixos/packages/<hostname>/`: Host package lists; every `.nix` file is imported automatically for that host and the existing lists respect their package group's enable option.
- `pkgs/`: Custom packages (`easydotnet`), exposed via the overlay and as flake outputs.
- `overlays/`: Nixpkgs overlays.
- `lib/`: Reusable Nix helpers; the overlay exposes `pkgs.optimizeForArch`.
- `shells/`: Development environments (`nix develop .#py`, `.#cpp`, `.#qksh`, `.#avalonia`, ...).
- `users/`: User account declarations (e.g. `melal`).

Heavy media assets (wallpapers, videos, profile pictures) and standalone configs (quickshell, neovim) live in their own dedicated repositories and are automatically wired up by the `assets-setup` script.

## Adding a new machine

1. Create `hosts/<name>/` with:
   - `meta.nix` — `{ users = [ "melal" ]; }` (accounts must exist under `users/`)
   - `hardware-configuration.nix`
   - `default.nix` — set `networking.hostName`, toggle `my.*` options
   - `home.nix` — import `../../modules/home`, set `my.home.*` options and host-specific session variables such as `BROWSER`
2. Track the new files with Git — the flake picks the host up automatically.

Host-specific system settings, such as `snowflake`'s GRUB OS probing, belong in `hosts/<name>/default.nix`. Shared modules do not branch on host names.

## Host features and package groups

Each package group has independent shared and host switches, both defaulting to
false. Both existing hosts explicitly enable both scopes for every group in
`hosts/<name>/default.nix`, preserving their existing selections.

```nix
my.packages = {
  cli = {
    shared.enable = true;
    host.enable = false;
  };
  gui = {
    shared.enable = false;
    host.enable = true;
  };
};
```

| Group | `shared.enable` controls | `host.enable` controls |
| --- | --- | --- |
| `cli` | Shared CLI utilities | The host's `cli.nix` list and CLI input packages |
| `gui` | Shared desktop applications and browser helpers | The host's `gui.nix` list and GUI input packages |
| `io` | Shared device/audio utilities | The host's `io.nix` list |
| `development` | Shared editor tools, language servers, formatters and debuggers | Host-only editor tools and individually selected global toolchains |
| `fonts` | Font packages, fontconfig and the Apple fonts overlay | A host's `fonts.nix` list, if present (neither current host has one) |

The former `my.packages.<group>.enable` options have been replaced by these two
scope switches. Every host package file is still imported automatically; new
lists should gate their contents with the matching `<group>.host.enable`.
Shared lists use `<group>.shared.enable`.

`pgmodeler` requires shared GUI and an enabled database feature. `pavucontrol`
requires shared I/O and at least one GUI scope. Snowflake's Helium follows host
GUI, while Tincan and Timr follow host CLI. TypeScript language servers, Prettier
and ESLint now belong to Snowflake's host development list; Watchman, Yarn, Bear
and Tree-sitter belong to shared development tools.

These groups control their own contributions. An enabled feature can still
install a package it needs independently of a package group. Base system tools
(`wget`, `curl`), the configured login shell, PipeWire, direnv and NixOS
system defaults remain independent of these package switches. Cache settings
remain unconditional and install no packages.

### Home Manager features and package ownership

`hosts/<name>/home.nix` enables the current user features explicitly:

| Option | Controls | Default |
| --- | --- | --- |
| `my.home.desktop.enable` | GTK/Qt styling, dconf preferences and cursor theme | false |
| `my.home.media.enable` | MPD, ncmpcpp, playerctld, MPC, playerctl, MPD MPRIS and playback notifications | false |
| `my.home.development.enable` | EditorConfig and the debugger path in session variables | Follows shared development |

Both existing hosts enable desktop styling and media. Git, Fastfetch, Yazi,
Lazygit, nh and Starship use their native `programs.<name>.enable` options
and are explicitly enabled in both host Home Manager files. Disabling nh also
removes its cleanup timer. Disabling shared development removes the default
Home Manager debugger reference, so that reference cannot retain the debugger
package after the group is disabled. An explicit `my.home.development.enable`
override remains available for standalone user configurations.

Home Manager owns installation of Git, Kitty, Foot, Ghostty, Yazi, Lazygit,
ncmpcpp, Fastfetch and Starship. Their duplicate NixOS package-list entries
have been removed. `my.programs.terminals.<name>.enable` sets a host default
for Home Manager; Home Manager installs and configures that terminal, including Foot's
user service. Apply the Home Manager configuration when changing these choices.
`programs.git.enable` controls both Git's installation and configuration. Set
it to false and apply Home Manager to remove its user installation. Removing
the previous system installation also requires applying the NixOS configuration.

`users/<name>/meta.nix` selects the login shell once. NixOS enables
`programs.${user.shell}.enable` for system shell integration. The user's Home
Manager module defaults the same option to true with `lib.mkDefault`,
so hosts can override it without repeating the default enable setting.

The login shell stays system-owned; Home Manager's Fish module also references
the same Fish build as required by the upstream module. Fish is not repeated in
the shared CLI package list. Disabling Home Manager's Fish option removes its
user configuration and installation, while NixOS retains the selected Fish
login shell. Identical outputs share one store path.

### Independent nix-ld compatibility

`my.programs.nix-ld.enable` defaults to false and is explicitly enabled on both
hosts. It preserves the existing compatibility libraries (X11, Qt, C++ runtime,
OpenGL, ICU and zlib). It is independent of every development/package-group
switch, so development tools and externally built binary compatibility can be
selected separately. NixOS's native `programs.nix-ld.enable` also remains usable.

| Feature | Global default | Snowflake | Rusty |
| --- | --- | --- | --- |
| `my.programs.noctalia.enable` | false | true | false |
| `my.services.nix-serve.enable` | false | true, interface `enp4s0` | false |
| `my.hardware.disablePcieWakeup.enable` | false | true | false |
| `my.programs.ipad-screen-mirror.enable` | false | true | false |

Noctalia uses its existing flake package and recommended services.
`my.programs.noctalia.optimize_for_arch` defaults to true and appends
`-march=<arch> -O3` while retaining existing compiler flags. Snowflake sets
`my.host.arch = "znver3"` once; hosts with different CPUs should set a
matching compiler architecture. The fallback is the host platform's compiler
architecture, or `x86-64`. Set `optimize_for_arch = false` to use the original
package without an override. Noctalia uses the shared `pkgs.optimizeForArch`
helper described below.

Home Manager's `my.home.noctalia.enable` defaults to the system Noctalia option.
It links the main TOML directly into this checkout, like Niri, so editing
`~/.config/noctalia/config.toml` edits
`modules/home/programs/noctalia/noctalia-config.toml` immediately. It also manages
the separate theme and wallpaper files, `black-mo.json`, and a generated,
read-only `~/.config/noctalia/plugins.toml`.
Each WM attaches its integration when both it and Noctalia are enabled; the Niri
fragment supplies startup and the existing `Mod+R/X/N/V` panel bindings. Enabling
Noctalia alone does not enable a WM. The unused Spicetify import was removed:
there is no active Spicetify configuration or locked input.

### Noctalia plugins

Each `my.home.noctalia.plugins.<name>.enable` defaults to false. Snowflake
explicitly enables the five plugins below; Rusty leaves them disabled.
The parent `my.home.noctalia.enable` gates their files, packages and activation.

| Plugin option | Noctalia plugin ID | Packages selected when enabled |
| --- | --- | --- |
| `discord-voice.enable` | `raycursive/discord-voice` | Python newer than 3.10 and Discord |
| `bongocat.enable` | `noctalia/bongocat` | evtest |
| `nix-search.enable` | `knyrps/nix-search` | nix-search-tv, fzf and xdg-utils |
| `pomodoro.enable` | `thepunkoff/pomodoro` | FFmpeg, including ffplay |
| `timer.enable` | `noctalia/timer` | None |

For example, in a host's Home Manager configuration:

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
Personal settings and styling belong in the host's Home Manager configuration;
Snowflake keeps its Pomodoro durations, Discord and Bongocat styling there.
Bar layout lives under `[bar.default]` in the editable main
`modules/home/programs/noctalia/noctalia-config.toml`, linked as
`~/.config/noctalia/config.toml`. Edit its `start`, `center` and `end` lists
directly; layout changes need no Home Manager switch. These lists are not
generated or filtered by Nix, so remove a plugin's widget name there when
disabling that plugin. Saved GUI bar overrides still take precedence over
the editable TOML until cleared manually in `settings.toml`.
Snowflake keeps its Discord widget preferences in its host Home Manager
configuration. It keeps its keyboard device path under
`my.home.noctalia.plugins.bongocat.widgets.cat.input_devices`. Other hosts
should select their own device paths and grant the user input-device access.
The existing user belongs to the `input` group.

Dependencies are installed through Home Manager, including when the system
CLI/GUI groups are disabled. Disabling a plugin removes its own package
additions; packages selected by other features or groups remain available.
The standalone nix-search-tv, fzf and Discord selections in the shared package
groups remain independent.

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

iPad mirroring keeps UxPlay, its firewall ports and Avahi discovery available.
Avahi's service and socket have no boot targets. Start discovery when needed:

```bash
sudo systemctl start avahi-daemon.service
uxplay
```

### Optimizing other packages from source

`lib/optimize-for-arch.nix` is exposed as `pkgs.optimizeForArch` by the shared
overlay. Set the architecture once in `hosts/<name>/default.nix`:

```nix
my.host.arch = "znver3";
```

The host module binds `pkgs.optimizeForArch` to that option, and Home Manager
inherits the same default through `osConfig`. Apply it to any source package
whose C/C++ build honors `NIX_CFLAGS_COMPILE`, without repeating the architecture:

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
Hosts without an explicit `my.host.arch` use the host platform's compiler
architecture, falling back to `x86-64`. Standalone use of the pure helper outside
a host configuration still takes an explicit `arch` argument. The Noctalia-only
architecture option has been removed; Noctalia uses `my.host.arch` too.

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
home-manager switch --flake .#<user>@<hostname>
```

The `.#<hostname>` Home Manager alias is also available when a host has exactly one configured user.

To build the custom package:

```bash
nix build .#easydotnet
```

## Development environments

Development environments are defined in `shells/`. Each environment also has a
`my.development.toolchains.<shell>.enable` option for installing its packages
globally. All default to false and take effect only while
`my.packages.development.host.enable` is true. Their definitions reuse the shell
packages through `shells/package-groups.nix`.

```nix
my.packages.development = {
  shared.enable = true; # Shared language servers, formatters and debugger tools.
  host.enable = true;   # Host editor tools and selected global environments.
};
my.development.toolchains = {
  cpp.enable = true;
  py.enable = true;
  py-science.enable = false;
  dotnet.enable = false;
};
```

Only selected environments contribute packages and retained outputs. Scientific
Python, Node.js, .NET/Avalonia, Rust, Go, Lua, JavaFX, Qt/QML and C/C++ companion
environments can be selected independently. Environments remain available via
`nix develop` regardless of their global installation switches.

To preserve current behavior, Snowflake explicitly selects every non-Java
shell; Rusty selects `cpp`, `audio`, `dpp`, `fmt`, `ncurses`, and `qksh`. These are
host choices and can now be reduced one environment at a time.

Enter an environment from this checkout with `nix develop .#<name>`, or from a project directory with:

```bash
nix develop ~/.dotfiles/nixos#cpp
nix develop ~/.dotfiles/nixos#cpp --command fish
```

Shell hooks do not replace your shell automatically, so commands and direnv activation can use them too.

| Shell | Environment |
| --- | --- |
| `cpp` | C/C++ tools, fmt, and nlohmann/json |
| `audio` | C/C++ environment plus libsndfile, ONNX Runtime, and PortAudio |
| `dpp`, `fmt`, `ncurses` | Focused C/C++ library environments |
| `qksh` | Quickshell and Qt/QML build dependencies |
| `py` | Python 3.13, uv, and native libraries for PyPI wheels |
| `py-science` | Python with requests, NumPy, Matplotlib, OpenCV, soundfile, and PyQt6 |
| `nodejs22` | Node.js 22, Bun, and TypeScript |
| `javafx` | JDK 21, Gradle, and JavaFX 21 |
| `dotnet`, `avalonia` | .NET 10 development; Avalonia adds its native runtime libraries |
| `rust`, `go`, `lua` | Language-specific toolchains |

Select global environments in `hosts/<name>/default.nix`. Add extra host editor tools to `modules/nixos/packages/<hostname>/development.nix`; shared editor tools remain in `dev/lsp.nix`. CLI package lists contain general command-line tools.

The host configurations explicitly retain the selected package outputs, including headers, through system generations; shell-specific settings such as Avalonia's `LD_LIBRARY_PATH` still apply when entering the shell. On Snowflake, the scientific Python environment supplies the default Python commands; the `py` shell uses plain Python 3.13 from the same locked package set. The desktop's QML-enabled Quickshell keeps priority over the plain build used by the `qksh` development shell.

For projects needing independently pinned versions, keep a `flake.nix` and `flake.lock` in the project itself. `direnv` and `nix-direnv` are enabled; a project `.envrc` containing `use flake` activates its default development shell after `direnv allow`.

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

The flake checks formatting, dead code, Nix linting, every development shell's Bash hook syntax, Niri with each home's generated browser/Noctalia fragments, asset bootstrap behavior, theme switching, module feature combinations, and each canonical Home Manager activation package. Home Manager checks build the generation without activating it. NixOS configurations are evaluated without switching the running system.

The `module-evaluation` check covers all shared/host combinations for each
package group, independent nix-ld, individual toolchain selection, disabled Home
Manager features and Noctalia integrations, application package ownership, and
architecture inheritance/overrides. It evaluates configuration without compiling
the selected applications. Run those assertions directly with:

```bash
nix eval --json --impure --expr '
  let f = builtins.getFlake (toString ./.);
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

The default browser is Firefox on `rusty` and LibreWolf on `snowflake`. Home Manager generates Niri's browser binding and environment from `home.sessionVariables.BROWSER`; `Mod+B` expands `$BROWSER` at launch.

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

`skwd-walld` provides unified image and video wallpaper rendering in Niri. `theme-switch` applies the selected media with `skwd-helm`, and Niri restores it at login. Press `Mod+Shift+W` to open the skwd-wall picker. Terminal reload signals are sent to Kitty (SIGUSR1) and Ghostty (SIGUSR2). Niri watches its included theme file; Noctalia receives `noctalia msg config-reload` after a theme or palette change.
