# Migration result — 2026-10-22

The final layout targets Melal across both machines, keeping standalone Home
Manager and the canonical homes `melal@rusty` / `melal@snowflake`. Their single-user hostname
aliases remain available. The lock file and both state versions (`24.11`) are
unchanged. No configuration activation or live service command was executed.

## Pinned-source verification

The current lock and evaluated input paths match the audit's revisions:
Nixpkgs `a033e66ab94a6bedf2c3d58d93a36319d3cbbbaf`, Home Manager
`32904dfe1cf86039f3c8c9f41f94e1cfd76dbb34`, unstable Nixpkgs
`7fd4004d0511991fff3a0524856a9be09e28c5f0`, Noctalia
`aa0aa81ad2432ca63634d49bb5380f5db2114888`, and Skwd
`f90814476e9d5b33c251f99e2388be1ddc9d5b36`.

The pinned HM MPD, EasyEffects and OBS modules and NixOS Avahi, Niri, recording
wrapper and upstream Noctalia/Skwd modules were inspected directly. In particular,
HM's MPD socket-activation module adds two listeners; the migration explicitly
replaces that list with a single private Unix socket. UXPlay's pinned 1.73.7
port behavior and Kitty 0.49.2 environment expansion were checked against their
upstream source/documentation rather than inferred from systemd syntax.

## Ownership and files

- `modules/home/` is Melal’s complete standalone Home Manager configuration. Its
  `default.nix` owns the fixed identity and common application/preferences defaults;
  `modules/home/hosts/{rusty,snowflake}/default.nix` supplies per-machine choices and data.
  There is no user discovery, user-membership metadata or generic user layer.
- `flake/hosts.nix` discovers `hosts/<host>/default.nix` and creates one NixOS
  configuration and one Melal home per host. Both `melal@<host>` outputs and the
  hostname aliases remain. Each machine requires a matching home entrypoint.
- `modules/nixos/system/melal.nix` declares the existing normal account, Fish
  login shell, supplementary groups and conditional GameMode membership.
  Account behavior and privileges are unchanged.
- Each host explicitly selects unconditional lists under `modules/home/packages/`,
  including its `rusty/` or `snowflake/` additions. There is no package-group
  enable option or default package bundle. Common preferences use leaf-level
  `lib.mkDefault`, so ordinary host settings can override a font or disable a
  common application without discarding unrelated settings.
- Foot remains size 14 on both actual hosts. Noctalia remains disabled on Rusty
  and enabled/configured on Snowflake. Its personal TOML is now
  `modules/home/hosts/snowflake/noctalia-config.toml`; either host can select a separate
  configuration. Host-override examples are covered by evaluation-only fixtures.
- Development settings and selected toolchains remain separate from editor
  package imports. `modules/home/dev/toolchains.nix` roots the same development outputs
  through `home.extraDependencies`. Project shells and hooks are unchanged.
  Stable/unstable choices, overrides and relative priorities are preserved by
  `modules/home/lib/after-home-packages.nix`.
- Hardware, filesystems, drivers, permissions, Niri/Ly/PAM/portals, audio services,
  networking/firewalls, Steam/GameMode, nix-ld, shared fonts, SQL deployment and
  nix-serve remain NixOS responsibilities, including administrative tools.
- Android webcam support remains consolidated in NixOS, including v4l2loopback,
  modprobe settings, scrcpy, v4l-utils and android-tools. Snowflake keeps
  `autoStart = false`. Shared I/O still selects android-tools independently,
  including on Rusty without enabling webcam hardware there.
- UXPlay remains consolidated with system Avahi and matching firewall rules under
  `my.programs.ipad-screen-mirror.enable`. Its normal-user launcher is manual;
  it does not start services. The separate Home Manager option remains removed.
- Terminal configuration uses native HM options. Runtime dependencies, private
  media paths, existing script preferences, CPU optimization and OBS plugins /
  GStreamer wrapping are preserved. Noctalia’s host networking, Bluetooth and
  power backends remain explicit NixOS capabilities.
- `modules/home/` is the single active Home Manager tree; the temporary top-level
  home tree was removed. Shared assets remain unchanged at their existing paths.
  The distinct legacy Niri `programs/wm/niri/config.kdl`, Noctalia
  `programs/noctalia/noctalia-config.toml`, and former user TOML remain byte-for-byte
  intact for live and rollback references. No existing runtime-owned link was
  retargeted. Cleanup of those old targets must wait until their references have
  been migrated and checked.

The initial uncommitted Pomodoro glyph changes, PSPP addition, removal of shared
OpenCode, and Snowflake's switch from OpenCode Desktop to OpenCode were carried
into their new owners. A complete original source snapshot, including those
edits and the three migration documents, is saved at:

`/home/melal/.cache/nixos-migration-20261022-lhdiard2/before`

`/home/melal/.cache/nixos-migration-20261022-lhdiard2/original-uncommitted.patch` records the initial tracked-file diff.
The audit, plan and prompt themselves remain unchanged.

Follow-up source snapshots, copies of removed helpers and before/after package
manifests are saved under:

`/home/melal/.cache/nixos-migration-20261022-lhdiard2/followups-jfijwwvt`

The source snapshot and package manifests for the final explicit-import cleanup
are saved under:

`/home/melal/.cache/nixos-migration-20261022-lhdiard2/explicit-imports-16juxhkq`

The single-user consolidation snapshot, evaluated before/after manifests and
legacy asset/link inventories are saved under:

`/home/melal/.cache/melal-single-user-or0uybft`

The source snapshot before consolidating the active tree at `modules/home/`
and removing the temporary top-level home tree is saved under:

`/home/melal/.cache/nixos-home-location-gu3hy44b`

## Startup and host dependencies

| Component | Final startup owner and policy |
| --- | --- |
| UXPlay | Manual system-installed launcher named `uxplay`; no service or automatic startup |
| Avahi | NixOS system service/socket, configured with no boot targets; manual policy retained |
| EasyEffects | HM graphical-session service; user approved automatic startup, restart on failure and stop at logout |
| GPU Screen Recorder UI | Niri startup, scoped to the user's processes; privileged recorder wrapper remains NixOS |
| Noctalia | Niri startup fragment; no enabled systemd unit |
| Skwd | Melal’s HM graphical-session unit; original command, model location, backend PATH and restart policy retained |
| OpenRGB | NixOS hardware server plus HM graphical-session tray client |
| MPD | HM socket activation using a private Unix socket; no TCP listener |
| playerctld / Nh cleanup | Existing HM user service / timer behavior retained |
| mpd-mpris | Installed, with no automatic service or launcher |
| MSSQL / nix-serve / Android webcam module | Existing manual policies retained |

**UXPlay still requires the system Avahi daemon running and the NixOS firewall
configuration.** `services.avahi.enable = true` describes configuration, cleared
`wantedBy` lists describe boot selection, and neither proves runtime health.
The existing D-Bus activation policy is unchanged. `publish.userServices` does
not isolate Avahi by user. UXPlay runs as the normal user.

The launcher checks system Avahi readiness and reports the missing dependency;
it never starts services or uses elevated privileges. It passes `-p 7000`, matching
the existing TCP/UDP 7000–7002 firewall openings. The module configures Avahi
publishing, mDNS and the receiver firewall rules. The user confirmed no external
UXPlay settings need preservation. Receiver name behavior is unchanged. Additional simultaneous
users would need disjoint port triples and distinct receiver/device identities;
no automatic allocation framework was introduced.

## Changed commands and paths

- `h-r` selects `melal@<host>`. The `#rusty` and `#snowflake` HM aliases remain
  available for the fixed single user.
- Both hosts use `BROWSER=helium`; LibreWolf stays available. Niri's browser keys
  use this selection. Previously referenced Swaylock and Orca commands now have
  explicit packages; NixOS's existing Niri PAM support remains in place.
- MPD, `MPD_HOST`, ncmpcpp and the notification helper agree on
  `~/.local/share/mpd/socket` (or the configured MPD data directory). The visualizer
  uses `~/.local/share/mpd/visualizer.fifo`. MPD state and music are retained.
  External clients previously using TCP 6600 need the Unix socket instead.
- Snowflake keeps plain Python ahead of its science environment, as the user
  selected. The science environment stays available with `nix develop .#py-science`.
  Stable FFmpeg from the existing Noctalia plugin stays ahead of the moved
  unstable FFmpeg; the QML Quickshell stays ahead of the plain shell build.
- Kitty expands `unix:$XDG_RUNTIME_DIR/kitty` and adds its instance PID. Systemd
  specifiers are not used in application configuration paths.
- New HM generations link Niri to `modules/home/programs/wm/niri/session.kdl`
  and Snowflake's Noctalia to `modules/home/hosts/snowflake/noctalia-config.toml`. The original `config.kdl` and
  `modules/home/programs/noctalia/noctalia-config.toml` remain byte-for-byte intact
  for existing and rollback generations. Keep them while still referenced.
- The unused `audio` helper and tmux-sessionizer were removed as requested,
  including their scripts, options, personal settings, generated files and the
  tmux-sessionizer key binding. Tmux remains installed. Mutable theme links are
  preserved.

During the source move, the two legacy Niri/Noctalia entry files were briefly
edited before their active out-of-store links were checked. They were restored
byte for byte; a file watcher may have observed those temporary edits. The new
paths avoid further changes to those active entry points. No activation, daemon
start/stop/reload/enable command, or runtime mirroring test was performed.

## Validation

Validation uses `path:$PWD` so untracked new files are included without staging
or committing. Commands use `--no-write-lock-file`. Nix evaluation/builds may fetch
sources and populate the store; no-build evaluation does not prohibit those writes.

All ten focused checks and the full no-build flake evaluation passed again
after consolidating the active tree at `modules/home/`. Both canonical home
activation packages and NixOS host outputs evaluate without activation.

After the NixOS consolidations, helper removals and package-file split, the
`module-evaluation`, `user-scripts`, `profile-priority`, `deadnix`, `statix` and
`formatting` checks passed, and the final no-build flake evaluation passed for
both hosts and canonical homes. The actual system UXPlay launcher also built
successfully, including its Bash syntax and ShellCheck checks; it was not run.

The single-user consolidation replaces alternate-user fixtures with Melal-only
package-list, host-override and custom MPD data-directory fixtures. Tests cover an
ordinary Foot font and media/shell preference overrides, independent Noctalia
configuration / disablement, account and alias preservation, and all existing
service/security boundaries.
Before/after evaluation preserves application package paths and priorities,
development roots, pinned inputs, account fields, state versions, session
variables, actual terminal/media settings and Noctalia selections. Both NixOS
system derivation paths and user services/sockets/timers match the snapshot,
including Avahi/firewall and manual webcam, mirroring, MSSQL and nix-serve policies.
Only the intended repository paths change: `vhm`, `xpkg`, future Niri/Noctalia
links and the theme-seeding helper now use `modules/home/`. The top-level home
tree is removed. All existing assets and four live links remain unchanged.

The consolidated tree passes all ten focused checks below, including all 44
regression assertions.

| Validation | Result |
| --- | --- |
| `nix flake check "path:$PWD" --no-build --no-write-lock-file` | Passed: both NixOS outputs, canonical homes, aliases, checks, shells and packages evaluate |
| `module-evaluation` | Built successfully; all 44 regression assertions pass, including ordinary terminal/media/Fish host overrides, package imports, custom media paths, account preservation, hardware ownership and startup policies |
| `niri-config` | Built successfully; both canonical homes, disabled applications and Rusty with alternate Noctalia validate |
| `assets-setup`, `theme-switch` | Built successfully; local fixtures cover idempotence, selected-link preservation, backup collisions and failure handling |
| `shell-hooks`, `user-scripts` | Built successfully; development shell hooks, generated Fish/startup scripts and helper script syntax pass |
| `deadnix`, `statix` | Built successfully and final direct checks pass |
| Formatting | Full treefmt check built successfully; direct pinned `nixfmt --check` also passes for every Nix file |
| `profile-priority` | Built successfully; tiny buildEnv probes using actual profile metadata verify Python, FFmpeg and Quickshell command precedence without building those applications |
| System UXPlay launcher | Built successfully with Bash syntax and ShellCheck validation; no receiver or service was started |
| Package-list simplification | Before/after evaluation matches every package path, priority and development root for both NixOS hosts and both canonical homes; unconditional common and host files are selected by each host’s imports |
| `git diff --check` | Passed |
| Preservation checks | Original documents, lock, legacy assets and live links are unchanged; evaluated account fields match the pre-consolidation baseline |

The initial and migrated evaluated package sets were compared by store path.
Every existing application path is retained except generated session-variable
files, the duplicate system Home Manager CLI, and raw UXPlay now referenced by
its wrapper. Previously selected toolchain roots are all retained: 28 on Rusty
and 78 on Snowflake, plus HM's generated completion dependencies. The pinned
OBS and CPU-optimized Noctalia constructions are preserved.

Full system/home application closures were not compiled. In particular, no
unnecessary CPU-optimized application rebuild was requested. Evaluation and these
checks do not establish runtime audio, GPU/camera, screen locking, service startup,
AirPlay discovery, firewall reachability or multiple simultaneous sessions. Those
need verification after the user chooses to activate.

## Staged activation and rollback — for the user, not executed

1. Review `git diff`, `git status --short`, new files and this report. Keep the
   source snapshot above. Record `readlink -f /run/current-system` and the prior
   entry from `home-manager generations`. New files must be tracked before using
   a Git flake; alternatively continue using `path:$PWD`.
2. Build the chosen host and canonical home without activation, allowing the
   application closure downloads/builds when convenient:

   ```bash
   migration_host=snowflake # or rusty
   nix build --no-link --no-write-lock-file "path:$PWD#nixosConfigurations.$migration_host.config.system.build.toplevel"
   nix build --no-link --no-write-lock-file "path:$PWD#homeConfigurations.\"melal@$migration_host\".activationPackage"
   ```

3. Log out of the graphical session to avoid overlap with already-running old
   launches. From a TTY, apply the canonical home first so moved commands exist,
   then apply NixOS to remove old package/unit ownership:

   ```bash
   migration_host=snowflake # or rusty
   home-manager switch --flake "path:$PWD#melal@$migration_host"
   sudo nixos-rebuild switch --flake "path:$PWD#$migration_host"
   ```

   Log into a fresh graphical session. Verify browser/terminal keys, exactly one
   instance of each graphical application, private MPD playback/visualizer,
   EasyEffects, recording, OpenRGB and wallpaper/theme persistence.
4. For mirroring, an administrator manually starts `avahi-daemon.service`; then
   the user runs `uxplay`. Check discovery and media with the sending device.
   MSSQL, nix-serve and the webcam module remain manual operations too.
5. If needed, leave the graphical session and restore the previously recorded
   HM generation using its `activate` program, then use
   `sudo nixos-rebuild switch --rollback` (or select the prior boot generation).
   The old mutable entry files are retained for that rollback. Restore source
   deliberately from the saved snapshot before rebuilding an old configuration;
   do not overwrite later work blindly. Generations do not roll back database
   data, secrets, mutable themes or external repositories.
