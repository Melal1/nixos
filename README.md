# NixOS & Home Manager Configuration

This repository contains my declarative NixOS and Home Manager configuration.

## Directory Structure

The structure of this flake is designed to strictly separate system-level (NixOS) modules from user-level (Home Manager) configurations, providing clear boundaries and minimizing redundancy.

- `flake.nix`: The main entry point, defining the inputs and outputs (hosts and home configurations).
- `hosts/`: Host-specific system configurations.
  - `hosts/desktop/` (alpha): Configuration for the desktop machine.
  - `hosts/laptop/` (zeta): Configuration for the laptop machine.
- `modules/`: Shared modules.
  - `modules/nixos/`: NixOS system-level modules (hardware, packages, system services, system UI/WM).
  - `modules/home/`: Home Manager user-level modules (programs, shell, user UI themes/GTK, scripts, assets).
- `users/`: User account declarations (e.g., `melal`).

## Features

- **Multi-host support**: Easily share modules across different machines (desktop and laptop).
- **Decoupled Architecture**: Host-specific logic is kept in the `hosts/` directory, while generic modules are shared in `modules/`.
- **Home Manager Integration**: Standalone Home Manager configuration that integrates cleanly with the system setup.

## Getting Started

To build and apply a system configuration:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

To build and apply a Home Manager configuration:

```bash
home-manager switch --flake .#<hostname>
```
