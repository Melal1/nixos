# Configuration reference

Source snapshot: 2026-11-09, including working-tree changes. Direct selections and custom options; dependency closure omitted. R = `rusty`, S = `snowflake`, — = neither. Both: `x86_64-linux`, user `melal`, `/home/melal`, NixOS/HM state version `24.11`.

## Structure / composition

| Path | Role |
|---|---|
| [flake.nix](flake.nix), [flake.lock](flake.lock) | Inputs, pinned revisions, flake-parts, platform, exports |
| [flake/hosts.nix](flake/hosts.nix) | Discovers `hosts/*/default.nix`; constructs NixOS and standalone Home Manager |
| `hosts/<host>/` | `default.nix`: system choices; `hardware-configuration.nix`: disks/hardware; `kernel.nix`: kernel; `home.nix`: presets/features; `home-packages.nix`: personal packages; `noctalia-config.toml`: full independent shell settings |
| `hosts/<host>/overrides/` | Automatically imports regular, top-level `*.nix` |
| `modules/nixos/{system,hardware,ui,packages,programs}/` | System modules; feature switches under `my.*` |
| `modules/home/` | `default.nix`/`core.nix`: identity/core; `presets/`, `packages/`, `programs/`, `shell/`, `dev/`, `scripts/`, `lib/`; `gtk.nix`: styling |
| `shells/`, `shells/package-groups.nix` | Independent project environments; reusable SDK/library selections |
| `pkgs/`, `overlays/`, `lib/` | EasyDotnet, Btop patch, CPU optimization helper |
| `flake/checks.nix`, `tests/`, `treefmt.nix`, `statix.toml` | Checks, fixtures, Nixfmt, lint settings |

- NixOS owns account/groups/login shell, hardware, services, networking/firewall, fonts, privileged wrappers. HM owns personal apps/configuration/scripts.
- NixOS imports `modules/nixos`; HM imports `modules/home` + optional host `home.nix` + overrides. Missing home/overrides leaves shell core. User identity is explicit; no user discovery.
- Both homes import `desktop` + `development` presets, `cli`, `desktop-apps`, `io`, `database-clients`, and host packages. Scalar/list defaults generally use `mkDefault`; ordinary host assignments override them.
- Host modules receive `inputs`, `unstable`, `hostname`; HM also receives `self`, NixOS `osConfig`. CPU overlay and capability assertions connect the two configurations; activation is separate.

## Inputs

GitHub sources below use `owner/repo[/ref]`. Exact revisions are in `flake.lock`. Apple fonts, Serein and WinApps follow unstable.

| Input | Source | Use |
|---|---|---|
| `nixpkgs` | `NixOS/nixpkgs/nixos-26.05` | Default packages/system |
| `nixpkgs-unstable` | `NixOS/nixpkgs/nixos-unstable` | Explicit newer packages; Rusty kernel |
| `discord-tmp` | `NixOS/nixpkgs/nixos-unstable` | Independently pinned Discord for Snowflake |
| `home-manager` | `nix-community/home-manager/release-26.05` | Standalone homes |
| `flake-parts` | `hercules-ci/flake-parts` | Flake composition |
| `treefmt-nix` | `numtide/treefmt-nix` | Formatter/check |
| `apple-fonts` | `Lyndeno/apple-fonts.nix` | System font overlay |
| `helium-flake` | `oxcl/nix-flake-helium-browser` | Browser, R/S |
| `noctalia` | `noctalia-dev/noctalia` | Desktop shell, R/S |
| `skwd-wall` | `liixini/skwd-wall/nix` | Wallpaper suite/model, R/S |
| `tincan-cli` | `bilalyazicioglu/tincan-cli/develop` | Available as a flake input |
| `toofan` | `vyrx-dev/toofan` | S |
| `serein` | `ViceVerse-cz/Serein` | Snowflake typing practice |
| `neovim-nightly-overlay` | `nix-community/neovim-nightly-overlay` | Neovim nightly for both homes |
| `rea-flake` | `Fractal-Tess/rea-flake` | Snowflake REA module and package |
| `winapps` | `winapps-org/winapps` | Windows app integration, S; follows unstable |

Exports: `nixosConfigurations.{rusty,snowflake}`; `homeConfigurations.{melal@rusty,melal@snowflake}` with identical `{rusty,snowflake}` aliases; `packages.x86_64-linux.easydotnet`; 14 `devShells`; Treefmt `formatter`; 14 `checks`. No exported apps, NixOS modules, or overlays; module/overlay files are used internally.

## Hosts / system defaults

| Setting | Rusty | Snowflake |
|---|---|---|
| CPU optimization target | `tigerlake` | `znver3` |
| Kernel | Unstable `linuxPackages_latest` | Stable `linuxPackages_zen`; NTFS support |
| Graphics | Intel VAAPI/iHD + proprietary NVIDIA production driver matching kernel | AMD + 32-bit graphics, LACT, overdrive |
| Power/input | Battery, deep sleep, libinput; Intel KVM/microcode | Performance governor, `amd_pstate=active`; AMD KVM/microcode |
| Disks / boot | ext4 `/`, vfat `/boot`, swap; GRUB EFI | Same layout; GRUB OS prober enabled |
| Extra system packages | `acpi`, `iw`, `linux-wifi-hotspot` | Feature-owned packages below |
| Extra home features | R/RStudio, Noctalia, hardware clients | Same + JS/Go/Rust, Avalonia, scientific Python, recording/OBS, EasyEffects, OpenRGB |

Shared: `Asia/Riyadh`; English default + Saudi Arabic locale; flakes/`nix-command`; unfree packages; `wget curl lsof`; Fish login shell; groups `wheel networkmanager uinput input adbusers dialout` (+ S `gamemode kvm`). NetworkManager, WireGuard support, OpenSSH, resolved, PipeWire/Pulse, uinput. Both select Niri/ly, GTK portal, Qt, dconf, unstable Xwayland Satellite, Bluetooth, QMK/VIA rules, nix-ld, shared fonts, Podman MSSQL, UPower and power-profiles-daemon. GRUB does not modify EFI variables. Printing, ZeroTier, Waydroid, auto-cpufreq and Docker disabled; S keyd Esc→`~` settings exist but keyd is disabled.

Fonts: SF Pro/Arabic/Mono/Compact/New York; Noto/CJK/emoji; Twitter emoji; Atkinson Hyperlegible; Iosevka; Sarasa; Nerd Fonts Iosevka/Caskaydia Cove/JetBrains Mono/Agave/Fira Code; Radio Canada Big. Fontconfig defaults: mono `SF Mono → Iosevka Nerd Font → Noto Naskh Arabic`; sans `SF Pro Text → SF Arabic → Noto Sans`; serif `New York → SF Arabic → Noto Naskh Arabic`; emoji `Twitter Color Emoji`; RGB subpixel.

Caches: default Nix cache plus `noctalia.cachix.org` and `nix-community.cachix.org` with trusted keys.

## Custom NixOS options

Prefixes below are literal option paths; braces list alternatives. All switches in this table default to `false`.

| Option(s) | Enabled | Provides |
|---|---|---|
| `my.desktop.niri.enable` | R/S | Niri session, ly, portals, Qt/Xwayland |
| `my.hardware.{bluetooth,vial-qmk}.enable` | R/S | Device support / keyboard udev rules |
| `my.hardware.gpu.{intel,nvidia}.enable` | R | Intel media drivers; proprietary NVIDIA, settings; NVIDIA power management off |
| `my.hardware.gpu.amd.enable` | S | AMD graphics, LACT, overdrive |
| `my.hardware.touchpad.enable` | R | libinput |
| `my.hardware.battery.{present,optimization.enable}` | R | UPower, power-profiles-daemon, deep sleep; optimization requires battery |
| `my.hardware.{performance,rgb,disablePcieWakeup}.enable` | S | AMD tuning; OpenRGB all-plugins server TCP 6742; PCIe bridge wake workaround |
| `my.hardware.androidWebcam.enable` | S | scrcpy, v4l-utils, ADB, v4l2loopback `/dev/video1` |
| `my.packages.fonts.shared.enable` | R/S | Font collection/defaults above |
| `my.programs.nix-ld.enable` | R/S | External binary loader + X11/Qt6/C++/GL/ICU/zlib libraries |
| `my.programs.steam.enable` | S | Steam/custom runtime, steamcmd, MangoHud, gamemode, Proton GE/protontricks; remote-play/server firewall |
| `my.programs.gpu-screen-recorder.enable` | S | Unstable recorder + privileged KMS wrapper |
| `my.programs.ipad-screen-mirror.enable` | S | Wrapped UXPlay, manual Avahi, mDNS + receiver firewall |
| `my.virtualisation.podman.enable` | R/S | Reusable Podman engine; required by MSSQL and WinApps |
| `my.virtualisation.mssql.enable` | R/S | Manual Podman SQL Server 2022 container |
| `my.virtualisation.winapps.enable` | S | Rootless Windows VM prerequisites, KVM group; HM integration follows through `osConfig` |
| `my.virtualisation.docker.{enable,autoStart}` | — | Optional Docker; service/socket boot activation follows `autoStart` |
| `my.services.nix-serve.enable` | S | Manual signed LAN binary cache |

| Other option(s) | Default → current selection |
|---|---|
| `my.packages.optimization.arch` | Host-platform GCC arch or `x86-64` → R `tigerlake`, S `znver3`; validated architecture string |
| `my.hardware.androidWebcam.autoStart` | `true` → S `false` (kernel module remains available) |
| `my.programs.ipad-screen-mirror.{package,port,receiverName}` | Unstable `uxplay`, `7000`, `null`; port starts a 3-port TCP/UDP range, maximum `65533` |
| `my.services.nix-serve.{interface,port,keyName}` | Required interface, `5000`, `<hostname>-1` → S `enp4s0`, `5000`, `snowflake-1` |

## Home Manager options / apps

Prefix: `my.home.`. Feature switches in the next table and development table default to `false`; core/presets/hosts enable selections shown.

| Option(s) | Enabled | Provides |
|---|---|---|
| `scripts.enable` | R/S (core) | Personal commands + tmux config |
| `desktop.enable` | R/S (desktop preset) | Adwaita-dark GTK, Qt GTK theme, macOS cursor size 48 |
| `media.enable` | R/S (desktop preset) | MPD, ncmpcpp, playerctld, mpc/playerctl, mpd-mpris, notifications |
| `wm.niri.enable` | R/S (desktop preset) | Editable Niri config, clipboard/history, display tools, OCR; requires system Niri |
| `skwd.enable` | R/S (desktop preset) | Wallpaper suite/semantic model + graphical-session `skwd-walld` |
| `{noctalia,keyboardTools,bluetoothClient}.enable` | R/S (hosts) | Shell/plugins; QMK/Vial/VIA clients; bluetui |
| `openrgb.enable` | S | Tray user service; requires system OpenRGB server |
| `gpu-screen-recorder-ui.{enable,autostart}` | S | Unstable GTK/UI/notification frontends + login overlay; Snowflake's UI enable follows its NixOS recorder switch |
| `winapps.launcher.enable` | S | Optional tray launcher; main WinApps integration follows NixOS, no HM enable option |
| `obs.gstreamer.enable` | S | OBS GStreamer UDP/RTP + software decoders; requires OBS enabled |
| `scripts.vicinae.enable` | — | Optional GitHub menu/dependency; also requires username |

| Other option(s) | Default / selection |
|---|---|
| `dotfilesDir` | String `/home/melal/.dotfiles/nixos`; editable checkout root |
| `wm.niri.startupCommands` | Lines, `""`; Skwd/recorder contribute commands |
| `noctalia.optimize_for_arch` | Boolean `true`, both hosts |
| `noctalia.package` | Noctalia input package through host `optimizeForArch` |
| `noctalia.configFile` | Nullable TOML path; existing `<dotfilesDir>/hosts/<host>/noctalia-config.toml`, otherwise `null` (active theme + upstream defaults); replaceable |
| `skwd.{modelPackage,extraPackages}` | Input `skwd-lens-model`, `[]` extra backends |
| `winapps.{windowsVersion,ramSize,cpuCores,diskSize}` | `"11", "8G", 4, "128G"`; generated rootless Compose, manual VM start |
| `scripts.githubUsername` | Nullable validated username; `null` → core `melal1` |
| `scripts.assets.{url,httpsUrl,quickshellUrl,neovimUrl,neovimBranch}` | `null,"",null,null,""` → core `git@github.com:Melal1/assets.git`, HTTPS fallback, `git@github.com:Melal1/{quickshell,neovim}.git`, Neovim branch `unstable` |

Core apps: Home Manager CLI, Fish (grc/fzf-fish, vi keys, `rgn`/`rgi` search helpers), Git (`main` branch; `melal`/`melal.1@hotmail.com`), Starship, Zoxide, Direnv/nix-direnv, Fastfetch, Yazi (Onedark; Rose Pine available), Lazygit/delta, Nh (`--keep-since 4d --keep 3` cleanup), tmux, ripgrep, bat, lsd, grc, fzf. Both host package files select nightly Neovim. `EDITOR` defaults to `nvim` when enabled and `nano` otherwise.

Desktop preset also enables unstable Kitty (Caskaydia Cove 18) and Foot/server (SemiBold 14), `BROWSER=helium`; browser installed by bundle. Ghostty configuration/themes exist but it is disabled. Media uses `~/Audio`, PipeWire + visualizer FIFO, private socket activation (`0600` socket/`0700` directory), no MPD TCP listener. S enables `services.easyeffects.enable` (requires dconf/PipeWire) and `programs.obs-studio.enable`; OBS plugins: wlrobs, background removal, PipeWire audio, vkcapture, AMD VAAPI, GStreamer.

## Package bundles / host additions

Stable unless marked `U:` (unstable) or `I:` (flake input); dependencies and packages already covered above omitted.

| Source | Direct selections |
|---|---|
| `packages/cli.nix` (R/S) | fd, tree, eza, unzip, jq, moreutils, bc, tealdeer, lolcat, figlet; U: zip, rar, yt-dlp, herdr |
| `packages/desktop-apps.nix` (R/S) | xdg-user-dirs, Nautilus, Papirus, Font Manager, Bibata, Proton VPN, qBittorrent, unoconv, Sioyek, Obsidian, Xournal++, mpv, Gwenview, Wine WoW64 stable, Winetricks, LibreWolf; U: LocalSend, Telegram, qpwgraph; I: Helium |
| `packages/io.nix` (R/S) | jmtpfs, alsa-utils, pavucontrol |
| `packages/database-clients.nix` (R/S) | sqlcmd, pgmodeler; U: lazysql |
| `packages/container-clients.nix` (not imported) | docker-compose |
| R `home-packages.nix` | Btop, brightnessctl, nmgui, android-tools, Codex, Rider, Discord, smassh; U: FFmpeg |
| S `home-packages.nix` | android-tools, Rider, btop-rocm, ImageMagick, Kdenlive, puddletag, KeePassXC, Prism Launcher · U: Codex, cloudflared, AnyDesk, VLC, FFmpeg · I: Discord (`discord-tmp`), Toofan, Serein |

## Development / shells

HM prefix: `my.home.dev.`. Parent `<group>.enable` installs toolchain + editor tools; nested library/framework switches work independently (R `ide` requires R enabled). Development preset enables R/S rows except R/RStudio, selected explicitly by hosts. Project shells remain independent.

| HM option / enabled hosts | `nix develop .#<shell>` | Toolchain / HM additions |
|---|---|---|
| `cpp.enable` R/S | `cpp` | GCC, Clang/tools, Make, CMake, Ninja, pkg-config, Premake, GDB; HM: cpptools debugger (`CODELLDB_PATH`), Bear, cmake-language-server |
| `cpp.dpp.enable` R/S | `dpp` | GCC/Make/CMake/pkg-config; DPP, opusfile, liboggz, fmt |
| `cpp.fmt.enable` R/S | `fmt` | GCC/Make/CMake/pkg-config, fmt |
| `cpp.ncurses.enable` R/S | `ncurses` | GCC/Make/pkg-config, ncurses |
| `cpp.qksh.enable` R/S | `qksh` | GCC/CMake/Ninja/pkg-config, Quickshell, Qt base/declarative; shell QML path |
| `csharp.enable` R/S | `dotnet` | .NET 10, CSharpier, EasyDotnet, netcoredbg; HM: Roslyn LS; shell `DOTNET_ROOT` |
| `csharp.avalonia.enable` S | `avalonia` | .NET 10, Skia/GUI/native libraries; shell library path/template hints |
| `python.enable` R/S | `py` | Python 3.13, uv, wheel runtime libraries; HM: Pyright/Ruff/mypy; shell library path, clears `PYTHONPATH` |
| `python.science.enable` S | `py-science` | Python with requests, soundfile, NumPy, Matplotlib, OpenCV Full, PyQt6 |
| `r.{enable,ide}` R/S | — | U: R + RStudio, both with nortest/ggplot2/dplyr |
| `javascript.enable` S | `nodejs22` | Node 22/Bun/TypeScript; HM: Watchman/Yarn, TS/Tailwind/web language servers, Prettier/ESLint; shell local npm bin path |
| `lua.enable` R/S | `lua` | Lua/LuaJIT; HM: StyLua, U: EmmyLua LS/Lua LS |
| `go.enable` S | `go` | Go; HM: gopls |
| `rust.enable` S | `rust` | Cargo/rustc/rustfmt/Clippy; HM: rust-analyzer |
| `java.enable` R/S; `java.javafx.enable` — | `javafx` | Parent: JDK 21 + JDT LS; optional JavaFX/shell: JDK/OpenJFX 21, Gradle, native GUI libs/paths |
| `{nix,shell,json,xml,text}.enable` R/S | — | nil/nixpkgs-fmt; ShellCheck/shfmt/Bash LS; vscode-langservers-extracted; libxml2; Harper |

C++ library defaults follow `cpp.enable` in the preset. Any enabled parent adds EditorConfig + unstable tree-sitter. SDK/library packages are deduplicated with development/runtime outputs rooted through `home.extraDependencies`; HM selection does not run shell hooks/export shell environments. Priorities preserve GCC over Clang linker commands and Lua over LuaJIT; S plain Python takes precedence over science Python, stable Noctalia FFmpeg over host unstable FFmpeg; global Quickshell comes from `qksh`.

## Runtime configuration / helpers

- Niri: editable `~/.config/niri/config.kdl` → checkout `session.kdl`; generated browser/app/Noctalia fragments; optional runtime `monitor.kdl`. US/Arabic, Alt+Space layout toggle, Caps→Esc. Super shortcuts: Q Foot, Shift+Q Kitty, B browser, R launcher, X session, N control center, V clipboard, S screenshot; media/brightness bindings follow features/battery.
- Noctalia includes: active `default.toml` → full independent `hosts/<host>/noctalia-config.toml`; GUI `~/.local/state/noctalia/settings.toml` overrides last. Bar/dock, launcher, clipboard, notifications/OSD, polkit; own wallpaper renderer disabled. Plugins both: Bongocat, Nix Search, Pomodoro, Timer; S adds Performance Plus. Neither host enables Discord Voice. Each host TOML owns all shell/bar/plugin/device/monitor settings. Dependencies include evtest, nix-search-tv, fzf, xdg-utils, stable FFmpeg.
- Theme state: mutable Kitty/Ghostty/Niri/Noctalia/palette links + `~/.local/state/theme/{wallpaper,video,media}`; activation only seeds missing links. `theme-switch --list` / `theme-switch <theme> [wallpaper-name|--random]` uses `~/.local/share/assets/themes/`, optional app/image/video slots, reload signals and Skwd apply. Typed app settings, generated fragments and wrapped scripts are store-managed.
- `assets-setup`: clones/updates Melal1 assets, Quickshell config, Neovim config; links Pictures Wallpapers/Pfp and Videos Wallpapers; seeds themes/media, preserves replaced destinations as `.bk[.N]`. Run after initial switches; uses configured Git URLs.
- Other `~/.local/bin` helpers: `vmrss` process-tree RSS; `gengitcommit` staged-diff prompt to clipboard; `open-github-tmux` repo opener; desktop `bright up|down`; Niri `niri-autostart`; S `mpv-mix` mixes two recording audio tracks. Optional `vicinaegithub.sh` disabled.
- Compatibility only: old `programs/wm/niri/config.kdl` and `modules/home/hosts/*/noctalia-config.toml` symlinks to full host files remain for older generations.

## Packages / operations / checks

- EasyDotnet **3.4.25**: pinned NuGet archive, Linux x64 native payload patching, .NET 10 wrappers `easydotnet` / `dotnet-easydotnet`. Shared overlay patches Btop `GPUReclaim` memory accounting; OpenBLAS test bypass only on unused i686 platform.
- `pkgs.optimizeForArch`: accepts `package`, `arch`, optional `optimize_for_arch=true`; appends `-march=<arch> -O3`, prefers local build/disables substitution for that package; dependencies/stdenv unchanged. Host overlay supplies `arch`; currently used by Noctalia. HM checks disable optimization for portable builds; exported homes retain it.
- Apply: `sudo nixos-rebuild switch --flake .#<host>`; `home-manager switch --flake '.#melal@<host>'`. Fish abbreviations: `x-r`, `h-r`. Build only: `nix build '.#homeConfigurations.melal@<host>.activationPackage'` / `nix build .#easydotnet`. New Git-flake files must be tracked; use `path:$PWD#…` while untracked.
- MSSQL (R/S): `sudo systemctl start podman-mssql`; localhost `1433`, persistent `mssql-data`, required `/var/lib/secrets/mssql.env`; no boot start.
- WinApps (S): apply NixOS and HM, log in again, create private `~/.config/winapps/{windows.env,winapps.conf}` from their examples, then manually run `podman-compose --file ~/.config/winapps/compose.yaml up -d` to install Windows. Console `127.0.0.1:8006`, RDP `127.0.0.1:3389`; persistent rootless `winapps_data` volume. Run `winapps-setup` when Windows is ready. [Full setup](README.md#winapps).
- UXPlay (S): `sudo systemctl start avahi-daemon`, then `uxplay`; receiver TCP/UDP `7000–7002`; Avahi service/socket have no boot target. Android webcam (S): manual `sudo modprobe v4l2loopback`, then scrcpy; no boot module load.
- LAN cache (S): `sudo systemctl start nix-serve`; interface `enp4s0`, TCP `5000`; activation creates `/var/lib/nix-cache/{cache.sec,cache.pub}` outside store/Git. Clients supply its HTTP URL + public key via Nix `extra-substituters` / `extra-trusted-public-keys`; no persistent Rusty LAN-cache selection. Stop manual services with `sudo systemctl stop`.
- Validate: `nix fmt`; `nix flake check`. Checks: `formatting`, `deadnix`, `statix`, `font-matching`, `home-composition`, `module-evaluation`, `profile-priority`, `shell-hooks`, `user-scripts`, `niri-config`, `theme-switch`, `assets-setup`, `home-melal@rusty`, `home-melal@snowflake`. Covers fonts/composition, feature combinations/overrides/provenance, command priorities, script syntax/behavior, Niri, both home builds. Source report verification: exported names evaluated successfully; no rebuild/activation performed.
