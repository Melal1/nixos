# NixOS & Home Manager Configuration

This repository contains my declarative NixOS and standalone Home Manager configuration.

## Directory Structure

- `flake.nix`: Entry point. Hosts are auto-discovered from `hosts/`; `mkHost`/`mkHome` build the configurations.
- `hosts/`: One directory per machine, named after the flake output.
  - `hosts/snowflake/`: Desktop machine. `hardware-configuration.nix` + a thin list of `my.*` toggles.
  - `hosts/rusty/`: Laptop machine.
  - `hosts/<name>/meta.nix`: Per-host metadata (`users`) read by the flake.
- `modules/`: Shared modules, all host-agnostic.
  - `modules/nixos/`: System modules. Features are gated behind `my.*` enable options.
  - `modules/home/`: Home Manager modules (programs, shell, dev, scripts).
  - `modules/nixos/packages/<hostname>/`: Host package lists; every `.nix` file is imported automatically for that host.
- `pkgs/`: Custom packages (`easydotnet`), exposed via the overlay and as flake outputs.
- `overlays/`: Nixpkgs overlays.
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

Development environments are defined in `shells/`. Snowflake also installs the packages from every non-Java shell globally; Rusty installs the C/C++ packages from `cpp`, `audio`, `dpp`, `fmt`, `ncurses`, and `qksh`. These host lists are derived from the shells through `shells/package-groups.nix`, keeping the package builds aligned.

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

Each host's `modules/nixos/packages/<hostname>/development.nix` selects its shared shell package group. Add extra tools to `cli.nix` or another `.nix` file in that host's package directory. Daily editor tools and language servers remain in the shared `dev/lsp.nix` module.

The host configurations explicitly retain the selected package outputs, including headers, through system generations; shell-specific settings such as Avalonia's `LD_LIBRARY_PATH` still apply when entering the shell. On Snowflake, the scientific Python environment supplies the default Python commands; the `py` shell uses plain Python 3.13 from the same locked package set. The desktop's QML-enabled Quickshell keeps priority over the plain build used by the `qksh` development shell.

For projects needing independently pinned versions, keep a `flake.nix` and `flake.lock` in the project itself. `direnv` and `nix-direnv` are enabled; a project `.envrc` containing `use flake` activates its default development shell after `direnv allow`.

## On-demand LAN cache

Snowflake can serve its existing Nix store to Rusty over Ethernet on port 5000.
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

The flake checks formatting, dead code, Nix linting, every development shell's Bash hook syntax, the shared Niri configuration, asset bootstrap behavior, and each canonical Home Manager activation package. Home Manager checks build the generation without activating it. NixOS configurations are evaluated without switching the running system.

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
3. Seeds the default terminal theme (`vague`) for kitty and ghostty only when their theme paths are absent, preserving any selected themes.
4. Seeds the theme indirection links (only if absent — never clobbers the current theme):
   - `~/.local/state/theme/wallpaper` → `~/.local/share/assets/wallpapers/default.jpg`
   - `~/.local/state/theme/video` → `~/.local/share/assets/videos/rain2k.webm`
   - `~/.local/state/theme/media` → `~/.local/share/assets/wallpapers/default.jpg`
5. Applies the current media link through `skwd-helm` if `skwd-walld` is running.

When replacing an existing asset destination, setup moves it to `.bk`, `.bk.1`, and so on, preserving earlier backups. A failed backup stops setup before the original destination is replaced.

Niri automatically configures outputs until `nwg-displays` creates `~/.config/niri/monitor.kdl`. The include is optional, and existing monitor configurations remain editable. Niri also starts and supervises `xwayland-satellite` on demand.

The default browser is Firefox on `rusty` and Helium on `snowflake`. `Mod+B` opens the host's configured `$BROWSER`.

## Themes & wallpapers

Terminal themes (kitty `~/.config/kitty/current.conf`, ghostty `~/.config/ghostty/theme`) and the active wallpaper (`~/.local/state/theme/media`) are **mutable symlinks**: Nix manages the configs that reference these stable paths, while `theme-switch <name>` re-points them — no rebuild needed.

Themes are directories in `~/.local/share/assets/themes/<name>/` with slot-named symlinks (`kitty`, `ghostty`, `video`, `wallpaper` or a `wallpapers/` dir of choices; missing slots are skipped):

```bash
theme-switch --list            # list available themes
theme-switch vague             # switch; multi-wallpaper themes use default.*
theme-switch vague river       # pick a wallpaper by (sub)name
theme-switch vague --random    # pick a random wallpaper from the theme
```

`skwd-walld` provides unified image and video wallpaper rendering in Niri. `theme-switch` applies the selected media with `skwd-helm`, and Niri restores it at login. Press `Mod+Shift+W` to open the skwd-wall picker. Terminal reload signals are still sent to kitty (SIGUSR1) and ghostty (SIGUSR2).
