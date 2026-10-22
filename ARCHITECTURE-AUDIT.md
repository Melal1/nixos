# NixOS + Home Manager Architecture Audit

**I recommend a partial migration.** Your configuration already separates NixOS and standalone Home Manager. The useful work is to move personal application choices into user configurations, improve a few service boundaries, and remove assumptions that currently limit multiple users.

I inspected the current working tree, including its existing uncommitted changes. I did not modify or create files, run builds, update inputs, activate configurations, or rebuild the system.

**A. Current architecture**

**Flake and import structure**

[flake.nix](/home/melal/.dotfiles/nixos/flake.nix:4) uses flake-parts and targets `x86_64-linux`. Its principal outputs are:

- `nixosConfigurations.rusty` and `nixosConfigurations.snowflake`.
- `homeConfigurations."melal@rusty"` and `homeConfigurations."melal@snowflake"`.
- Compatibility aliases `homeConfigurations.rusty` and `.snowflake`, available because each host currently has exactly one configured user.
- Development shells, the custom `easydotnet` package, a formatter, and checks.

[flake/hosts.nix](/home/melal/.dotfiles/nixos/flake/hosts.nix:17) discovers hosts through `hosts/<name>/meta.nix`. It discovers users only when their `meta.nix`, `nixos.nix`, and `home.nix` all exist. Each host’s metadata selects its users; references to unknown users produce an error.

The active import flow is:

```text
flake.nix
├── flake/hosts.nix
│   ├── nixosConfigurations.<host>
│   │   ├── skwd-wall NixOS module
│   │   ├── hosts/<host>/default.nix
│   │   │   ├── hardware-configuration.nix
│   │   │   ├── kernel.nix
│   │   │   └── modules/nixos/default.nix
│   │   │       ├── host options
│   │   │       ├── system
│   │   │       ├── UI
│   │   │       ├── packages
│   │   │       ├── hardware
│   │   │       └── programs
│   │   └── users/<user>/nixos.nix
│   └── homeConfigurations."<user>@<host>"
│       ├── users/<user>/home.nix
│       └── hosts/<host>/home.nix
│           └── modules/home/default.nix
│               ├── programs
│               ├── shell
│               ├── development
│               ├── scripts
│               └── desktop styling
└── flake/checks.nix
```

This is **standalone Home Manager**. You do not import `home-manager.nixosModules.home-manager` or populate `home-manager.users`.

However, standalone does not mean evaluation is independent: [the constructor explicitly passes `osConfig`](/home/melal/.dotfiles/nixos/flake/hosts.nix:74) from the corresponding NixOS configuration. Home Manager uses it to inherit several feature defaults.

**Pinned versions and verification**

The lock file pins:

| Input | Declared branch | Locked revision |
|---|---|---|
| Nixpkgs | `nixos-26.05` | `a033e66ab94a6bedf2c3d58d93a36319d3cbbbaf` |
| Home Manager | `release-26.05` | `32904dfe1cf86039f3c8c9f41f94e1cfd76dbb34` |
| Unstable Nixpkgs | `nixos-unstable` | `7fd4004d0511991fff3a0524856a9be09e28c5f0` |

Sources: [Home Manager lock](/home/melal/.dotfiles/nixos/flake.lock:326), [stable lock](/home/melal/.dotfiles/nixos/flake.lock:362), [unstable lock](/home/melal/.dotfiles/nixos/flake.lock:439).

I matched locally available source trees to these lock entries using their registered NAR hashes. Relevant option semantics were checked in those trees, including the pinned Noctalia and Skwd modules.

This is a source and import audit, **not a successful full-flake evaluation or runtime test**. “Enabled” below describes the imported declarations and their conditions; it does not assert that a service is currently running.

**Configured hosts and users**

| Host | System configuration | User configuration |
|---|---|---|
| `rusty` | Intel/NVIDIA laptop; unstable latest kernel; battery optimisation; Bluetooth; touchpad integration; QMK/Vial; Niri and Ly; manually started MSSQL container; nix-ld | Fish; Kitty and Foot; desktop styling; MPD/ncmpcpp/playerctld; Git, Fastfetch, Yazi, Lazygit, Nh, Starship |
| `snowflake` | AMD desktop; Zen kernel; NTFS support; AMD performance tuning and LACT; Bluetooth; QMK/Vial; OpenRGB; PCIe wake workaround; manually loaded Android webcam module; Niri and Ly; MSSQL; nix-serve; Steam/GameMode; OBS; GPU Screen Recorder; EasyEffects; UXPlay/Avahi; Noctalia | Common user features plus OpenRGB client, Noctalia configuration and five selected plugins; Niri autostarts for EasyEffects and GPU Screen Recorder; `BROWSER=helium` |

Sources: [Rusty system](/home/melal/.dotfiles/nixos/hosts/rusty/default.nix:3), [Rusty home](/home/melal/.dotfiles/nixos/hosts/rusty/home.nix:1), [Snowflake system](/home/melal/.dotfiles/nixos/hosts/snowflake/default.nix:9), [Snowflake home](/home/melal/.dotfiles/nixos/hosts/snowflake/home.nix:1).

The only explicitly declared normal user is `melal`, selected on both hosts. Its shared metadata supplies the home directory, Fish login shell, Home Manager state version, and supplementary groups. The NixOS account module additionally grants `gamemode` membership when GameMode is enabled. Sources: [user metadata](/home/melal/.dotfiles/nixos/users/melal/meta.nix:1), [account declaration](/home/melal/.dotfiles/nixos/users/melal/nixos.nix:9).

**Packages and package sets**

Most package installation still happens through NixOS:

| Package group | Current contents and scope |
|---|---|
| Shared CLI | `jq`, network inspection tools, tmux, archives, search/navigation tools, zoxide, fzf, grc, Home Manager CLI, tealdeer; unstable Neovim, herdr, zip, yt-dlp, rar and FFmpeg. Lazysql follows database availability. [List](/home/melal/.dotfiles/nixos/modules/nixos/packages/cli.nix:8) |
| Shared GUI | Browsers, Discord, Rider, Obsidian, MPV, document/image applications, Wine, Proton VPN, qBittorrent, themes and cursors; unstable LocalSend, qpwgraph and Telegram. PgModeler follows database availability. [List](/home/melal/.dotfiles/nixos/modules/nixos/packages/gui.nix:9) |
| Shared I/O | jmtpfs, ALSA utilities, Android tools; pavucontrol additionally requires a GUI package group. [List](/home/melal/.dotfiles/nixos/modules/nixos/packages/io.nix:8) |
| Shared development | Debuggers, language servers, formatters and editor helpers, including your custom EasyDotnet package. [List](/home/melal/.dotfiles/nixos/modules/nixos/packages/dev/lsp.nix:9) |
| Rusty additions | btop, smassh, brightnessctl, Codex, nmgui, acpi, iw, linux-wifi-hotspot. [CLI](/home/melal/.dotfiles/nixos/modules/nixos/packages/rusty/cli.nix:8), [GUI](/home/melal/.dotfiles/nixos/modules/nixos/packages/rusty/gui.nix:8), [I/O](/home/melal/.dotfiles/nixos/modules/nixos/packages/rusty/io.nix:8) |
| Snowflake additions | btop-rocm, ImageMagick, iamb, Codex, cloudflared; desktop applications including Prism Launcher, LibreOffice, VLC, AnyDesk and OpenCode; NTFS tools and additional web development tools. [CLI](/home/melal/.dotfiles/nixos/modules/nixos/packages/snowflake/cli.nix:9), [GUI](/home/melal/.dotfiles/nixos/modules/nixos/packages/snowflake/gui.nix:8), [development](/home/melal/.dotfiles/nixos/modules/nixos/packages/snowflake/development.nix:9) |
| Input packages | Snowflake installs Helium, tincan-cli and timr-tui conditionally through its package groups. [Declarations](/home/melal/.dotfiles/nixos/hosts/snowflake/default.nix:109) |
| Fonts | Both hosts install the shared font collection, including Apple fonts, Noto, Iosevka and Nerd Fonts, with shared fontconfig defaults. [Configuration](/home/melal/.dotfiles/nixos/modules/nixos/packages/fonts.nix:9) |

“Shared” and “host” in `my.packages` both mean **system installation**. They distinguish reusable lists from machine-specific lists, not system packages from user packages.

Home Manager already installs Git, Fastfetch, Yazi, Lazygit/Delta, Starship, Nh, Kitty and Foot, plus the media commands and selected Noctalia plugin dependencies. OpenRGB’s client unit references its executable directly by store path, so it does not require a separate `home.packages` entry to run.

Stable and unstable coexist explicitly. Your base overlay adds EasyDotnet, an architecture optimisation helper, a btop patch, and an i686 OpenBLAS test override. The Apple-font overlay is added by the NixOS font module. Unstable is imported separately with unfree packages allowed; it does not receive your base overlays. Sources: [package construction](/home/melal/.dotfiles/nixos/flake/hosts.nix:8), [base overlay](/home/melal/.dotfiles/nixos/overlays/default.nix:1).

Noctalia is currently the active use of `optimizeForArch`: Snowflake’s `znver3` setting adds compilation flags and bypasses substitutes for that selected package. It does not retune the whole package set. [Implementation](/home/melal/.dotfiles/nixos/lib/optimize-for-arch.nix:9).

The active input roles are clear: QML tooling and Quickshell/Niri packages support the desktop; Skwd supplies wallpaper infrastructure; Apple fonts supply fonts; Noctalia supplies its shell/module; Helium and the two CLI inputs supply Snowflake applications. `pi` and `antigravity-nix` are declared inputs without active package/module consumers in the configuration inspected.

**Services, disabled features and external state**

Both hosts enable NetworkManager, OpenSSH, resolved, PipeWire/Pulse compatibility and uinput. WireGuard support is enabled, but no WireGuard interfaces or peers are declared. [Networking](/home/melal/.dotfiles/nixos/modules/nixos/system/networking.nix:1), [shared services](/home/melal/.dotfiles/nixos/modules/nixos/system/services.nix:1).

Important distinctions:

- MSSQL is configured on both hosts, but `autoStart=false`.
- Snowflake’s nix-serve has no boot target.
- Snowflake’s Avahi service and activation socket have their boot targets cleared.
- Android webcam support installs the kernel module, but `autoStart=false` means it is not requested at boot.
- Noctalia starts through a Niri startup fragment; its upstream systemd service option is not enabled.
- `mpd-mpris` is installed, but no service or autostart launches it.
- Docker, Waydroid, ZeroTier, printing, Ghostty and Snowflake’s keyd service are disabled. Defining keyd mappings does not enable keyd.

Secrets are external runtime files:

- MSSQL reads `/var/lib/secrets/mssql.env`.
- nix-serve references `/var/lib/nix-cache/cache.sec`, generated during system activation if absent.
- No SOPS/agenix integration is present in the active configuration.
- Binary-cache public keys are public trust configuration.

I did not read secret files or expose secret values. Sources: [MSSQL](/home/melal/.dotfiles/nixos/modules/nixos/system/virtualisation.nix:28), [cache signing](/home/melal/.dotfiles/nixos/modules/nixos/system/nix-serve.nix:30).

**B. Responsibility audit**

“Both” means separate host capabilities and user behavior, not two modules owning the same setting.

| Component | Current location | Recommended location | Feasible? | Reason |
|---|---|---|---|---|
| Hardware, filesystems, swap, firmware, kernels | `hosts/*/hardware-configuration.nix`, `kernel.nix` | **NixOS; retain per host** | Yes | Machine resources and boot environment. |
| Bootloader | [system/bootloader.nix](/home/melal/.dotfiles/nixos/modules/nixos/system/bootloader.nix:1) | **NixOS** | Yes | Privileged boot configuration; share only among compatible hosts. |
| GPU drivers, graphics libraries, AMD overdrive | [GPU modules](/home/melal/.dotfiles/nixos/modules/nixos/hardware/gpu/amd.nix:10) | **NixOS** | Yes | Kernel, driver and shared graphics integration. |
| LACT | AMD GPU module | **NixOS daemon**; optional user UI | Yes | Hardware control affects the host GPU. A personal UI does not make GPU settings private. |
| NetworkManager, resolved, OpenSSH, WireGuard | `system/networking.nix` | **NixOS** | Yes | Host networking, DNS and remote access. |
| Firewall | UXPlay, Steam and cache modules | **NixOS** | Yes | Rules govern host traffic independently of who installed an application. |
| Accounts, login shell, groups | `users/melal/nixos.nix` | **NixOS** | Yes | Account and permission management. |
| Fish preferences and plugins | `modules/home/shell` | **Home Manager** | Already | User shell behavior. NixOS still registers the login shell. |
| Direnv/nix-direnv | System module plus manual Fish hook | **Home Manager**, unless deliberately shared | Yes | Personal development integration; no daemon requires system ownership. |
| Personal CLI/GUI applications | NixOS package groups | **Mostly Home Manager** | Yes | Individual package selections need no system rebuild. Privileged integration remains separate. |
| Network/admin tools | NixOS CLI lists | **Either**, according to intended audience | Yes, with limits | Installing nmap/arp-scan for a user does not grant raw-network privileges. |
| LSPs, formatters, debuggers | NixOS development lists | **Home Manager** | Yes | User editor dependencies. |
| Project toolchains and libraries | NixOS groups plus `shells/` | **Development shells**, with selected global tools in HM | Yes | Project environments preserve versions, hooks and library paths. |
| nix-ld | [programs/nix-ld.nix](/home/melal/.dotfiles/nixos/modules/nixos/programs/nix-ld.nix:11) | **NixOS** | Yes | Loader integration requires system paths; installing its package in HM is insufficient. |
| Fonts | NixOS font module | **Both**, or retain shared NixOS fonts | Yes | Shared fonts are reasonable; personal defaults and extra fonts can be per user. |
| Niri and Ly | NixOS desktop modules | **Both** | Yes | Keep session registration, PAM and desktop prerequisites in NixOS; bindings/layout/preferences in HM. |
| Portals, keyring, D-Bus, polkit | Desktop modules and upstream defaults | **NixOS baseline**, user preferences where useful | Yes | Session infrastructure should remain coherent across applications. |
| PipeWire and WirePlumber | NixOS shared services | **NixOS baseline**, optional HM configuration | Yes | NixOS already provisions user instances and host integration. |
| EasyEffects | System package/dconf; Niri startup script | **Both** | Yes | Host supplies audio/dconf; HM supplies package, presets and optional user service. |
| GPU Screen Recorder | NixOS program/wrapper/frontends; HM autostart | **Both** | Partially movable | Keep the capability wrapper in NixOS; move frontends and personal startup choices to HM. |
| OBS | NixOS program and plugin module | **HM application/plugins**, host prerequisites in NixOS | Yes | Current OBS configuration does not enable its virtual-camera option. Preserve your GStreamer override. |
| Steam and GameMode | NixOS gaming module | **Retain NixOS integration**; user preferences/additional tools in HM | Yes | Includes graphics, hardware rules, firewall and privileged helpers. |
| Avahi | UXPlay NixOS module | **NixOS** | Yes | Shared host mDNS/DNS-SD daemon. |
| UXPlay | UXPlay NixOS module | **HM package/config/optional user service**, NixOS discovery/firewall | Yes | Normal receiver operation need not run as root. |
| OpenRGB | NixOS server; HM client | **Both; preserve split** | Already | Host owns hardware detection/access; user owns tray client and preferences. |
| QMK/Vial/VIA | Hardware module packages and rules | **Both** | Yes | Keep udev rules in NixOS; GUI/CLI tools can be per user. |
| Android webcam | Hardware module | **Both** | Yes | Keep v4l2loopback/modprobe/device access in NixOS; scrcpy and capture tools can move to HM. |
| Bluetooth | Hardware module plus bluetui | **Both** | Yes | BlueZ is host infrastructure; bluetui is a personal client. |
| auto-cpufreq, UPower, power profiles | Battery module; Noctalia recommended services | **NixOS** | Yes | Manage shared power state and hardware capabilities. |
| PCIe wake workaround, CPU tuning, uinput | Hardware/system modules | **NixOS** | Yes | Kernel settings and device permissions. |
| Noctalia | System package/services; HM files/plugins | **Both** | Yes | Shell/config/plugins are personal; networking, Bluetooth and power backends remain host capabilities. |
| Skwd wallpaper daemon | NixOS module creates global user unit | **HM for selected users**, or retain deliberately global | Yes | It already runs as a user service; no privileged operation appears in its module. |
| MPD, ncmpcpp, playerctld | HM media module | **HM; retain** | Yes, after multi-user fixes | Personal music state/session audio belong to the user. |
| Nh cleanup | HM Nh module | **HM; retain** | Already | Upstream creates a user cleanup service/timer. |
| MSSQL container | NixOS virtualisation module | **NixOS for current deployment** | Yes | Root-managed lifecycle, secrets and persistent volume are already coordinated there. |
| SQL clients and PgModeler | System package lists | **HM or project shell** | Yes | A client does not need to follow local server enablement. |
| nix-serve and cache signing | NixOS cache module | **NixOS; retain** | Yes | System cache, credential delivery, firewall and persistent identity. |
| Dotfiles and helper scripts | HM modules | **HM** | Already | Improve dependency declarations and user-specific values. |
| Mutable assets, external editor configs | `assets-setup` and external repositories | **Neither as immutable state**, unless you choose to pin them | Deliberate exception | HM can distribute the bootstrap tool while external repositories remain independently managed. |
| Overlays, custom packages, checks | `overlays/`, `pkgs/`, `tests/` | **Shared flake infrastructure** | Already | These support both layers rather than belonging exclusively to either. |

Several classifications need additional explanation.

**Avahi and UXPlay**

[Your UXPlay module](/home/melal/.dotfiles/nixos/modules/nixos/programs/ipad-screen-mirror.nix:15) installs UXPlay, enables Avahi publishing, opens mDNS and receiver ports, and removes Avahi’s boot targets.

Avahi remains a host service even though it drops privileges to its dedicated account. Its pinned NixOS module provisions that account, a shared socket, system D-Bus integration and the firewall rule. `publish.userServices=true` permits client service publication; it does not create an Avahi instance for each user or restrict publication to `melal`. [Pinned Avahi module](https://raw.githubusercontent.com/NixOS/nixpkgs/a033e66ab94a6bedf2c3d58d93a36319d3cbbbaf/nixos/modules/services/networking/avahi-daemon.nix).

Restricting access to a system daemon would require explicit authorization policy. It still would not make the host’s network identity, multicast traffic or advertisements private to that user. Your configuration contains no such user restriction.

For UXPlay itself, the pinned package is **1.73.7**. Its documentation supports rootless user services and requires distinct ports/device identities for simultaneous users. It also documents dynamic ports unless configured with `-p`; `-p 7000` selects 7000–7002 for TCP and UDP. Your repository opens those ports but supplies neither a matching launch argument nor an `.uxplayrc`. A manual command or external file could supply it, so this is a **declarative coordination gap**, not proof your current receiver fails. [UXPlay documentation](https://github.com/FDH2/UxPlay/tree/v1.73.7).

A practical split is:

- NixOS: Avahi publishing, its lifecycle, and appropriate firewall rules.
- HM: UXPlay installation and receiver configuration.
- Optional HM user service: tied to the graphical session when automatic reception is desired.
- Manual launch: sensible for occasional mirroring.

A user unit cannot acquire a dependency on the system manager’s Avahi unit by adding `Requires=avahi-daemon.service`; dependencies resolve within its own manager. Keep shared daemon startup a host decision. System and user units have separate search paths and managers. [systemd unit documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html).

Version 1.73.7 also documents a BLE discovery alternative. That is a separate setup, not something your configuration currently enables.

**Audio, desktop and recording services**

PipeWire demonstrates why process ownership alone is insufficient. Its pinned NixOS module defaults `systemWide=false` and enables **user** PipeWire/Pulse units; WirePlumber follows that model. Keeping this configuration in NixOS does not mean all users share one root audio daemon. [Pinned PipeWire implementation](/nix/store/mcw86k11xl4bnd6mhb7b93l34kxr13lz-source/nixos/modules/services/desktops/pipewire/pipewire.nix:391).

HM has verified `services.easyeffects.enable`, including package installation and a graphical-session user service. Its module also documents the NixOS dconf prerequisite. Moving EasyEffects there is straightforward, provided the existing Niri launch is removed to avoid two startup owners. [Pinned HM module](/nix/store/lrni36b7x68ray1ih2b803lrl8vg3bql-source/modules/services/easyeffects.nix:74).

GPU Screen Recorder is different: its NixOS module creates `gsr-kms-server` with `cap_sys_admin`. HM cannot reproduce that privileged wrapper through ordinary package installation. Keep that integration system-owned while making frontends and startup personal. [Pinned wrapper definition](/nix/store/mcw86k11xl4bnd6mhb7b93l34kxr13lz-source/nixos/modules/programs/gpu-screen-recorder.nix:30).

OBS can move substantially into HM: the pinned HM module supports application/plugin wrapping, and your NixOS OBS module does not enable virtual-camera setup. The AMD-specific plugin choice and custom GStreamer wrapper must survive the move. Any v4l2loopback setup remains in NixOS. [Current OBS configuration](/home/melal/.dotfiles/nixos/modules/nixos/programs/obs.nix:10), [pinned HM options](/nix/store/lrni36b7x68ray1ih2b803lrl8vg3bql-source/modules/programs/obs-studio.nix:15).

**Steam, Noctalia and Skwd**

Keeping Steam’s system integration is a useful exception. Its pinned module configures graphics support, Steam hardware rules and the selected firewall openings. GameMode also involves polkit and a capability wrapper despite using a user daemon. Merely placing Steam/GameMode packages in HM would lose these pieces. [Current gaming bundle](/home/melal/.dotfiles/nixos/modules/nixos/programs/steam.nix:34), [pinned GameMode integration](/nix/store/mcw86k11xl4bnd6mhb7b93l34kxr13lz-source/nixos/modules/programs/gamemode.nix:54).

Noctalia’s shell package can move to HM. Its pinned input exposes **`homeModules.default`**, but importing it is optional: your existing custom configuration module could simply own the package too. Avoid two modules declaring `noctalia/config.toml`.

The host services enabled by `recommendedServices` must remain explicit host decisions: NetworkManager, Bluetooth, UPower and, unless tuned is enabled, power-profiles-daemon. Currently they are introduced on Snowflake indirectly through the shell feature. [Pinned Noctalia module](/nix/store/ll83i3rfaphrjxj88rpw0prsrsa0805z-source/nix/nixos-module.nix:71).

Skwd’s NixOS module installs packages and defines `systemd.user.services.skwd-walld` globally. It is already a user process, but every applicable user receives the definition. HM is a better owner if only selected users want it. Preserve its model location, package paths and graphical-session lifecycle. [Pinned Skwd module](/nix/store/6ffb8c2wsn6xkpywaabhvg5pa2wci740-source/nix/nixos.nix:18).

**MSSQL and nix-serve**

Your MSSQL deployment is a system-managed Podman container, regardless of which account processes use inside the image. Moving its client tools to HM is easy; moving its deployment would involve different service ownership, secrets access, volume ownership and possibly port allocation.

Rootless deployment is technically possible, but it is a separate operational change. Retaining the current NixOS container is appropriate.

Similarly, nix-serve is a system service even though the pinned module runs it under a dynamic `nix-serve` identity. Systemd delivers the signing key through `LoadCredential`, so the root-owned key need not become readable by a desktop user. [Pinned cache implementation](/nix/store/mcw86k11xl4bnd6mhb7b93l34kxr13lz-source/nixos/modules/services/networking/nix-serve.nix:73).

Its interface-specific firewall rule does not bind its listener to that interface: the upstream bind address defaults to `0.0.0.0`. Your firewall restriction and listener binding are separate responsibilities.

**C. Problems and opportunities**

**1. User preferences currently follow host membership.**

Every selected user imports the same `hosts/<host>/home.nix`. Adding another user to Snowflake would therefore enable that user’s media setup, common applications and selected Noctalia plugins automatically.

Worse, [the reusable Git module contains Melal’s identity](/home/melal/.dotfiles/nixos/modules/home/programs/git.nix:2), while generic scripts contain personal repository URLs and a GitHub username.

Move personal identity and feature selections into `users/melal/home.nix`. Put machine-specific personal choices into a user/host override. Keep host-wide HM defaults limited and overridable.

**2. Terminal choices have unnecessary cross-layer indirection.**

Currently:

```text
NixOS my.programs.terminals.<terminal>.enable
    → HM my.home.terminals.<terminal>.enable
        → HM programs.<terminal>.enable
```

The NixOS terminal module only declares defaults; HM owns installation and configuration. There is no privileged dependency requiring this chain. [Host declarations](/home/melal/.dotfiles/nixos/modules/nixos/programs/terminals.nix:6), [HM bridge](/home/melal/.dotfiles/nixos/modules/home/programs/terminals/default.nix:8).

Use the existing HM program enable options directly and gate custom theme files with those options.

**3. The media setup is not ready for simultaneous users.**

[MPD](/home/melal/.dotfiles/nixos/modules/home/programs/mpd.nix:21) and [ncmpcpp](/home/melal/.dotfiles/nixos/modules/home/programs/ncmpcpp/default.nix:20) use:

- Shared loopback TCP port `6600`.
- Shared FIFO `/tmp/mpd.fifo`.

Two users cannot both bind the same address/port, and their visualizer FIFOs should not share a filename. Prefer a user-specific Unix socket where supported, or distinct ports, and a FIFO under a user-owned directory. Keep all clients consistent.

Kitty similarly specifies `unix:/tmp/kitty`; use a user-specific location for predictable multi-user behavior. [Setting](/home/melal/.dotfiles/nixos/modules/home/programs/terminals/kitty/kitty.nix:50).

**4. Shell and script dependencies are implicit.**

Fish calls zoxide and direnv supplied by NixOS. Direnv’s system module already enables Fish integration, while your HM Fish configuration adds another hook. [Manual hook](/home/melal/.dotfiles/nixos/modules/home/shell/fish.nix:102).

The script module installs desktop helpers unconditionally. Its `pkgs ? gh` condition tests whether the package attribute exists, not whether GitHub CLI—or the script’s actual dependencies—is installed. The script itself requires Vicinae, which is commented out in your package list. [Script installation](/home/melal/.dotfiles/nixos/modules/home/scripts/default.nix:60), [script requirements](/home/melal/.dotfiles/nixos/modules/home/scripts/vicinae-github.sh:19).

Follow the existing `assets-setup` pattern: declare runtime dependencies or place a helper inside the feature that supplies them.

**5. Some declared commands lack corresponding package selections.**

Rusty inherits `BROWSER=firefox`, while the shared GUI list installs LibreWolf and contains no Firefox declaration. Its generated Niri binding uses that browser variable.

The shared Niri file also references Helium, swaylock and Orca without corresponding explicit package selections on every host using that file. This does not establish what your existing interactive environment contains; it establishes that the repository does not fully express those command dependencies. [Browser default](/home/melal/.dotfiles/nixos/modules/home/shell/fish.nix:132), [bindings](/home/melal/.dotfiles/nixos/modules/home/programs/wm/niri/config.kdl:400).

**6. Some “shared” configuration is machine-specific.**

The shared Noctalia TOML contains layouts for `DP-1` and `HDMI-A-1`. The audio helper contains specific Bluetooth and microphone identifiers. These belong in Melal’s host overrides rather than universal defaults. [Noctalia outputs](/home/melal/.dotfiles/nixos/modules/home/programs/noctalia/noctalia-config.toml:101), [audio identifiers](/home/melal/.dotfiles/nixos/modules/home/scripts/audio.sh:7).

`my.host.displays` is declared and populated but has no configuration consumer. It does not currently generate those layouts.

**7. Some option interfaces provide little value.**

[Package groups](/home/melal/.dotfiles/nixos/modules/nixos/packages/default.nix:22) default off and are explicitly selected on both hosts. That is predictable.

However:

- `fonts.host.enable` has no host font list consuming it.
- The empty Rusty development file contributes nothing.
- Single-option wrappers sometimes duplicate upstream options without bundling meaningful behavior.
- Core system modules enable services unconditionally, so they are shared policy rather than universally optional features.

Keep custom options for useful bundles. For ordinary choices, use existing options and `mkDefault` where a shared default should permit normal overrides.

**8. Mutable configuration limits rollback guarantees.**

Niri and Noctalia’s main configuration files use out-of-store links into the checkout. Theme selections intentionally remain mutable. External Neovim/Quickshell repositories and Noctalia plugin code are not fully pinned by this flake. [Niri link](/home/melal/.dotfiles/nixos/modules/home/programs/wm/niri/default.nix:35), [Noctalia link](/home/melal/.dotfiles/nixos/modules/home/programs/noctalia/default.nix:23), [external repositories](/home/melal/.dotfiles/nixos/modules/home/scripts/assets-setup.nix:152).

These can remain deliberate exceptions. A generation rollback cannot restore the historical contents of a mutable checkout or downloaded plugin.

**9. Development shell reuse is good, but package extraction is not shell activation.**

[shells/package-groups.nix](/home/melal/.dotfiles/nixos/shells/package-groups.nix:6) reuses packages and preserves selected outputs. It does not apply `shellHook` settings when those packages are installed globally.

For example, the Avalonia, Python and JavaFX shells set library paths or runtime variables. Moving their package lists into HM would not change that limitation. Preserve the shells for project environments.

**10. Package duplication should be reduced selectively.**

Actual overlap includes Home Manager CLI in both layers, Discord through system packages and the Noctalia plugin, libnotify in both layers, and Android tools through overlapping system features.

Identical store paths do not become separate physical copies merely because two profiles reference them. The problem is unclear ownership and feature-disable behavior.

Fish being referenced by both layers is justified: NixOS owns login-shell registration; HM owns user configuration.

**11. Checks need broader user coverage.**

The existing checks are useful and already exercise feature combinations. However, [part of the evaluation suite](/home/melal/.dotfiles/nixos/tests/module-evaluation.nix:244) assumes the two hostname aliases and the two current hosts.

Extend it to canonical user/host outputs before relying on multiple users. I did not execute these checks during this read-only audit.

Also, file existence does not establish activation: `modules/home/dev/clangFormat.nix` is not imported, and the adjacent Yazi `init.lua`/`theme.toml` files are not selected by your current Yazi module.

**D. Proposed architecture**

Keep the existing shape and add a clear place for user/host differences:

```text
flake.nix
flake.lock

flake/
├── hosts.nix
└── checks.nix

hosts/
├── rusty/
│   ├── meta.nix
│   ├── default.nix
│   ├── hardware-configuration.nix
│   ├── kernel.nix
│   └── home.nix              # optional shared host defaults
└── snowflake/
    ├── meta.nix
    ├── default.nix
    ├── hardware-configuration.nix
    ├── kernel.nix
    ├── keyboard.nix
    └── home.nix

users/
└── melal/
    ├── meta.nix
    ├── nixos.nix             # account and granted permissions
    ├── home.nix              # identity, applications, preferences
    └── hosts/
        ├── rusty.nix
        └── snowflake.nix

modules/
├── nixos/
│   ├── default.nix
│   ├── host.nix
│   ├── system/
│   ├── hardware/
│   ├── programs/
│   └── ui/
└── home/
    ├── default.nix
    ├── programs/
    ├── services/             # when separating these improves navigation
    ├── packages/             # a few reusable application lists
    ├── shell/
    ├── dev/
    ├── scripts/
    └── gtk.nix

overlays/
pkgs/
lib/
shells/
tests/
```

The organizational rules are simple:

- **`hosts/` describes machines:** hardware, system capabilities and selected accounts.
- **`users/` describes people:** identity, applications, preferences and explicitly granted permissions.
- **`users/<user>/hosts/` describes their differences between machines.**
- **`modules/` contains reusable behavior**, with personal values supplied by the user configuration.
- **`shells/` retains project environments.**
- **`pkgs/` and `overlays/` remain shared packaging infrastructure.**

The Home Manager constructor would compose the user’s common home, optional shared host defaults, and the user/host override. Shared modules should use ordinary defaults where overrides are expected; import order alone does not give a later Nix definition priority.

Move host-specific personal package lists out of `modules/nixos/packages/<hostname>/`. Keeping true system additions directly in `hosts/<host>/default.nix` would also remove that second host directory hierarchy.

There is no need for a module registry, roles framework or generic dependency resolver.

**Optional feature interfaces**

| Feature | Host responsibility | User responsibility |
|---|---|---|
| Terminals | None beyond desktop prerequisites | Existing HM `programs.kitty.enable`, `programs.foot.enable`, etc. |
| UXPlay | Existing Avahi/firewall settings, optionally grouped by your current host bundle | Package, receiver configuration, optional user unit |
| EasyEffects | PipeWire and dconf | Existing HM `services.easyeffects.enable` |
| OpenRGB | Existing NixOS OpenRGB server option | Existing custom HM tray-client option |
| GPU Screen Recorder | Existing NixOS program option/capability wrapper | Frontends, settings and optional startup |
| Noctalia | Independently selected host backends | Shell package, configuration, plugins and startup |
| Android webcam | Kernel module and device permissions | Capture application and preferences |

A custom HM UXPlay option could be justified if it groups installation, configuration and service behavior. That would be a **new local option**, not an existing upstream option. It cannot configure the host firewall or Avahi.

Use the composition point to select both sides explicitly. Retain one-way `osConfig` reads for genuine capabilities where helpful; remove them for personal terminal and application preferences. Avoid making NixOS infer privileged settings by scanning HM package lists.

**Multi-host and multi-user behavior**

- **One user, multiple hosts:** common personal defaults in `users/melal/home.nix`; hardware-sensitive preferences in the user’s host files.
- **Multiple users, one host:** distinct homes and feature selections; account privileges remain NixOS-owned.
- **Selected host capabilities:** enable the NixOS feature only on hosts that support it.
- **Selected user applications:** enable them only in that user’s home.
- **Application needs a host capability:** select both explicitly, optionally validate the declared capability through `osConfig`.
- **Different architectures:** your constructor needs per-host platform selection. Skwd currently publishes only x86_64 packages, and the custom EasyDotnet recipe explicitly retains linux-x64 payloads; changing `system` alone would not make the whole configuration portable.

Your current discovery machinery can support this. Replacing it is unnecessary.

**E. Benefits and tradeoffs**

| Area | Benefit of the refinement | Cost or limitation |
|---|---|---|
| Ownership | Personal choices become easy to find | Related host and user settings sometimes occupy separate files |
| Multiple users | Users stop inheriting Melal’s identity and selections | Hardware permissions and shared services still need explicit policy |
| Multiple hosts | Hardware stays independent; personal defaults are reused | Hardware-sensitive application settings require overrides |
| Maintenance | Application changes need fewer system changes | Standalone system/home activations must remain coordinated |
| Debugging | Clear package, service and permission owners | Cross-layer failures still require inspecting both layers |
| Reuse | Modules become usable by another person | Some personal constants must become supplied values |
| Packages | Less accidental system-wide installation | A minimal administrative/recovery package set may still be useful |
| Predictability | Feature disablement becomes easier to understand | Mutable runtime state remains outside generation rollback |

Cross-layer dependencies and privilege boundaries are genuine technical tradeoffs. Repeating terminal flags across three option layers, copying identities into shared modules, and hiding package dependencies are implementation problems.

**Home Manager module versus standalone**

Both approaches support your desired separation.

| Choice | Fit for this repository |
|---|---|
| **Keep standalone** | Least migration work; independent user changes and rollbacks; preserves current outputs and workflow. Current `osConfig` use still couples evaluation to NixOS. |
| **Use the NixOS module** | Convenient coordinated system/home generations and account integration; user environment changes participate in the system deployment workflow. |

The pinned NixOS integration supplies `osConfig` automatically. `home-manager.useGlobalPkgs=true` shares the system package set and disables HM’s `nixpkgs.*` options; `useUserPackages=true` installs packages through the corresponding NixOS user package mechanism. Neither turns those packages into `environment.systemPackages`. [Pinned integration options](https://raw.githubusercontent.com/nix-community/home-manager/32904dfe1cf86039f3c8c9f41f94e1cfd76dbb34/nixos/common.nix).

If you adopt that integration:

- Remove HM’s package-set configuration when using `useGlobalPkgs`.
- Rely on automatically supplied `osConfig`.
- Preserve your user modules and host overrides.
- Check profile-path assumptions and activation timing.
- Avoid maintaining competing standalone and integrated activation owners for the same home.

**My recommendation is to keep standalone during the ownership cleanup.** Switch integration modes later only if coordinated deployment is more valuable to you than independent user updates.

**F. Technical limitations**

**Cannot be achieved by ordinary Home Manager declarations alone:**

- Kernel modules, boot configuration, system account creation, udev rules or host firewall rules.
- GPU Screen Recorder’s privileged capability wrapper.
- NixOS nix-ld loader integration.
- System Avahi ownership and policy.
- A system-unit dependency from a systemd user unit.

**Possible with restrictions:**

- User applications accessing cameras, GPUs, keyboards or network devices: host permissions remain necessary.
- Multiple UXPlay instances: coordinate ports, identities and advertisements.
- Multiple MPD instances: separate sockets/ports, state and FIFOs.
- Rootless database containers: migrate lifecycle, credentials, volume ownership and persistence deliberately.
- Per-user access restrictions on system services: use service-specific authentication, D-Bus/polkit policy, socket permissions or other supported mechanisms.

**Technically possible but undesirable for this configuration:**

- Running Avahi as a desktop-user substitute for the shared host daemon.
- Moving every NixOS-configured user daemon into HM merely because it runs under a user UID.
- Replacing established Steam, PipeWire or desktop integration with package installation alone.
- Starting privileged host services through `sudo` inside HM activation or user service commands.
- Building an elaborate cross-layer feature inference framework.

Package installation is also **not an access-control boundary**. HM controls a user’s profile and configuration; it does not generally make package executables private to that user.

A system service with `User=...` remains owned by the system manager. Conversely, NixOS can distribute user units globally. Your cache service, PipeWire setup and Skwd module illustrate these distinctions.

**G. Migration requirements**

The recommended partial migration would require:

1. **Preserve existing identities and state versions.** Keep current `system.stateVersion` and `home.stateVersion` values; they are compatibility settings, not migration targets.
2. **Add user/host composition.** Move Melal’s common enables and identity into the user home; move Snowflake-specific preferences into its user override.
3. **Transfer application ownership.** Move personal package groups, keeping a deliberate system baseline and existing privileged integrations.
4. **Preserve package construction.** Carry over unstable selections, OBS overrides, font availability and selected CPU optimisation.
5. **Update consumers.** Shells, Niri bindings and scripts must reference commands supplied by their owning features.
6. **Choose one startup owner per application.** Especially EasyEffects, Noctalia and Skwd.
7. **Correct shared runtime resources.** MPD ports/FIFO, Kitty socket and any simultaneous UXPlay instances.
8. **Preserve external state deliberately.** Database volumes, runtime secret files, signing keys, mutable theme links and external configuration checkouts.
9. **Update checks and shortcuts.** Use canonical `user@host` outputs. The current Fish `h-r` shortcut uses the hostname alias, which disappears when a host has multiple configured users.

Moving packages changes PATH/profile ownership and potentially shell completions, desktop entries and dependency closure. Moving services changes activation and restart behavior. Directory moves can break your out-of-store links and asset-script paths.

Neither standalone nor integrated rollback restores database contents, regenerated secrets, mutable dotfiles or externally downloaded plugins.

**H. Migration order**

A safe incremental sequence would be:

1. **Record the existing baseline:** selected options, packages, services, current generations and persistent-state locations.
2. **Separate personal values first:** Git identity, repository defaults and user/host preferences, preserving behavior.
3. **Introduce canonical user/host composition:** update aliases, shortcuts and tests before adding another user.
4. **Move a small set of uncomplicated applications:** verify command availability and desktop integration after each group.
5. **Simplify terminal and shell ownership:** remove redundant enable bridges and duplicate direnv startup.
6. **Move editor tools and personal development utilities:** retain project shells and their environment hooks.
7. **Move user-facing service pieces:** EasyEffects, UXPlay, Noctalia package ownership and optionally Skwd.
8. **Validate retained host capabilities:** recording wrapper, portals, audio, graphics, Avahi, hardware permissions and firewall.
9. **Exercise multiple-user behavior:** independent feature selections, MPD/Kitty resources and simultaneous graphical sessions.
10. **Consider integration mode separately:** adopt the NixOS HM module only if its deployment model is preferred.

After changes are authorized, validation should include the existing checks, targeted configuration evaluation, and runtime checks for affected service/session behavior. Those checks were not run here.

**I. Final recommendation**

Choose **partial migration with the current standalone Home Manager workflow**.

Retain your host discovery, reusable module structure, hardware configuration, system services and established NixOS integrations. Improve three areas first:

- Put personal application choices and identity under `users/`.
- Make user services and their dependencies explicit.
- Remove shared-port, shared-path and hostname-alias assumptions before adding users.

That reaches your architectural goals with modest changes. A wholesale rewrite or immediate change of Home Manager integration mode would add work without resolving the main issues more effectively.


