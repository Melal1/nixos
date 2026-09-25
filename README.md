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
- `pkgs/`: Custom packages (`easydotnet`), exposed via the overlay and as flake outputs.
- `overlays/`: Nixpkgs overlays.
- `shells/`: Dev shells (`nix develop .#py`, `.#dpp`, `.#quickshell`, `.#avalonia`, ...).
- `users/`: User account declarations (e.g. `melal`).

Heavy media assets (wallpapers, videos, profile pictures) and standalone configs (quickshell, neovim) live in their own dedicated repositories and are automatically wired up by the `assets-setup` script.

## Adding a new machine

1. Create `hosts/<name>/` with:
   - `meta.nix` — `{ windowManager = "niri"; }`
   - `hardware-configuration.nix`
   - `default.nix` — set `networking.hostName`, toggle `my.*` options
   - `home.nix` — import `../../modules/home`, set `my.home.*` options
2. Done — the flake picks the new host up automatically.

## Getting Started

To build and apply a system configuration:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

To build and apply a Home Manager configuration (standalone):

```bash
home-manager switch --flake .#<hostname>
```

To build the custom package:

```bash
nix build .#easydotnet
```

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
3. Links the default terminal theme (`vague`) for kitty and ghostty.
4. Seeds the theme indirection links (only if absent — never clobbers the current theme):
   - `~/.local/state/theme/wallpaper` → `~/.local/share/assets/wallpapers/default.jpg`
   - `~/.local/state/theme/video` → `~/.local/share/assets/videos/rain2k.webm`
5. Applies the current wallpaper link through `skwd-helm` if `skwd-walld` is running.

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
