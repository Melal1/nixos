# Melal's Home Manager configuration

`default.nix` declares Melal's identity and reusable modules, and imports
`core.nix` for the small shell setup. The flake optionally imports
`hosts/<host>/home.nix` from the repository root. A host without that file receives
the core; both current hosts import `presets/desktop.nix` and
`presets/development.nix`, optional shared package bundles and their colocated
`home-packages.nix`. See the [repository guide](../../README.md#adding-a-machine)
for an example.

Optional `hosts/<host>/overrides/` folders hold application differences. The
flake automatically imports regular top-level `.nix` files there; nested folders
and non-Nix files are ignored. Keep presets, features and package imports in
`home.nix`. Shared application defaults remain in `programs/`; create an override
only when a host needs a different value.

Core and presets select defaults; application modules own configuration and
runtime dependencies. Ordinary host assignments override scalar and list
preferences without `mkForce`. Shared `packages/*.nix` bundles are explicitly
imported and contain no feature-owned duplicates; host package files may retain
intentional duplicates and variants. Arduino IDE is selected only on Snowflake.
The desktop preset defaults `BROWSER` to `helium`; import `desktop-apps.nix` to
install it, or select and install another browser. Noctalia and hardware clients
remain host choices. NixOS manages fonts and fontconfig defaults in
`modules/nixos/packages/fonts.nix`, as well as privileged service prerequisites.

GPU Screen Recorder frontends use `my.home.gpu-screen-recorder-ui`; the NixOS
backend remains independent. Snowflake binds the UI's `enable` to
`osConfig.my.programs.gpu-screen-recorder.enable` in its host home file.

WinApps has one main switch: `my.virtualisation.winapps.enable` in NixOS.
`programs/winapps.nix` follows it through `osConfig`, with no separate Home Manager
enable. `my.home.winapps` only customizes VM resources and the optional launcher.
Home Manager generates Compose, OEM files and credential examples; actual
credentials, the Windows disk and discovered application shortcuts are runtime
state. See the [WinApps setup guide](../../README.md#winapps).

| File ownership | Examples | Editing |
| --- | --- | --- |
| Editable checkout files | Niri `programs/wm/niri/session.kdl`; Noctalia full root `hosts/<host>/noctalia-config.toml` | Edit directly, then reload |
| Immutable Home Manager files | Typed app settings, generated Niri fragments and Noctalia include wrapper, fallback themes/palettes, wrapped scripts | Change source and apply Home Manager |
| Runtime-owned state | Active theme/wallpaper links, Niri `monitor.kdl`, Noctalia state overrides | Use theme/display/application tools |

`my.home.dotfilesDir` locates editable checkout files. Noctalia's generated
`~/.config/noctalia/config.toml` includes the runtime theme `default.toml`, then
the full, independent `hosts/<host>/noctalia-config.toml`.
`my.home.noctalia.configFile` defaults to that host file when present; set it to
`null` for upstream defaults plus the active theme, or another absolute TOML
path. Editing included TOML requires only `noctalia msg config-reload`; adding or
removing a file from the include list requires a Home Manager switch. The app's
GUI overrides in `~/.local/state/noctalia/settings.toml` remain app-owned and load
last. Runtime theme links are still seeded only when absent.

The Noctalia module owns common plugin dependencies; the shell downloads and
updates plugins at runtime. Old `modules/home/hosts/<host>/` directories contain
only compatibility symlinks for older generations. Their targets at root
`hosts/<host>/noctalia-config.toml` hold the full host settings. New hosts do not
need the legacy symlinks.

The distinct legacy Niri `programs/wm/niri/config.kdl` remains for live and
rollback references; new generations select `session.kdl`. Keep the old target
until its references have been migrated and checked.

Native script bodies live in `scripts/*.sh` and Fish startup in `shell/init.fish`;
Nix wrappers provide dependencies and substitute preferences. Source changes do
not activate configurations or retarget runtime-owned theme links. Track/stage
new files for Git flake commands, or use `path:$PWD` while working with untracked
files.
