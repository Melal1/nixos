# NixOS & Home Manager Configuration

This repository contains my declarative NixOS and Home Manager configuration.

## Directory Structure

- `flake.nix`: Entry point. Per-host settings live in the `hosts` attrset; `mkHost`/`mkHome` build the configurations.
- `hosts/`: One directory per machine, named after the flake output.
  - `hosts/alpha/`: Desktop machine. `hardware-configuration.nix` + a thin list of `my.*` toggles.
  - `hosts/zeta/`: Laptop machine.
- `profiles/`: Shared defaults imported by hosts (e.g. `workstation.nix`).
- `modules/`: Shared modules, all host-agnostic.
  - `modules/nixos/`: System modules. Hardware features are gated behind `my.hardware.*` enable options.
  - `modules/home/`: Home Manager modules (programs, shell, scripts, assets). Host-specific config files are selected by `hostname` interpolation.
- `pkgs/`: Custom packages (`dwm`, `dwmblocks-async`, `xwinwrap`), exposed via the overlay and as flake outputs.
- `overlays/`: Nixpkgs overlays.
- `shells/`: Dev shells (`nix develop .#py`, `.#dpp`, ...).
- `users/`: User account declarations (e.g. `melal`).

## Adding a new machine

1. Create `hosts/<name>/` with its `hardware-configuration.nix`.
2. Write a thin `hosts/<name>/default.nix`: import the profile, set `networking.hostName`, and toggle `my.*` options (plus a `home.nix` with `my.home.*` settings).
3. Add one entry to the `hosts` attrset in `flake.nix`.

## Getting Started

To build and apply a system configuration:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

To build and apply a Home Manager configuration (standalone):

```bash
home-manager switch --flake .#<hostname>
```

To build a custom package:

```bash
nix build .#dwm
```
