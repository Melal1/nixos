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
- Development is selected through nested `my.home.dev` language modules. Each
  parent bundles its SDK/toolchain and editor tools, including its language server;
  C++ libraries, Avalonia, Python science and JavaFX have nested selections.
  The old development package lists and `my.home.development` switches are removed.
  Selected project-shell outputs are deduplicated and rooted by
  `modules/home/dev/toolchain-packages.nix`; editor additions remain separate from
  those roots. Existing project shells, hooks and package provenance are retained.
  Stable/unstable choices and priorities still use
  `modules/home/lib/after-home-packages.nix`.
- Hardware, filesystems, drivers, permissions, Niri/Ly/PAM/portals, audio services,
  networking/firewalls, Steam/GameMode, nix-ld, shared fonts, SQL deployment and
  nix-serve remain NixOS responsibilities, including administrative tools.
- The former `modules/nixos/host.nix` is split by responsibility. Package CPU
  targeting lives in `modules/nixos/packages/optimization.nix` as
  `my.packages.optimization.arch`; battery presence and optimization live in
  `modules/nixos/hardware/battery.nix` as `my.hardware.battery.present` and
  `my.hardware.battery.optimization.enable`. The unused display inventory is removed. Rusty keeps
  its battery services, power settings and Niri brightness controls; Snowflake
  keeps `znver3`. The optimization helper still changes only selected packages.
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
- Skwd and GPU Screen Recorder own their Niri startup commands in their respective
  application modules. Niri declares the mergeable
  `my.home.wm.niri.startupCommands` option and assembles the script. Wallpaper
  restoration precedes the recorder UI launch; existing conditions, backgrounding
  and process checks are preserved. The Skwd daemon uses its existing
  graphical-session service.
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

The source snapshot before introducing nested development groups and their
before/after manifests and validation logs are saved under:

`/home/melal/.cache/nixos-dev-groups-66k45wxu`

The commit-group preparation snapshot, staged-tree validation and final check
logs (including the plain Quickshell follow-up) are saved under:

`/home/melal/.cache/nixos-grouped-commits-w20_2v7g`

The snapshot before splitting the host metadata module, its original uncommitted
diff and before/after evaluation manifests are saved under:

`/home/melal/.cache/nixos-host-split-e692vw4y`

The snapshot before moving application startup commands, its original uncommitted
diff, generated-script comparisons and validation logs are saved under:

`/home/melal/.cache/nixos-startup-ownership-clam0ff8`

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
  use this selection. NixOS's existing Niri PAM support remains in place.
- MPD, `MPD_HOST`, ncmpcpp and the notification helper agree on
  `~/.local/share/mpd/socket` (or the configured MPD data directory). The visualizer
  uses `~/.local/share/mpd/visualizer.fifo`. MPD state and music are retained.
  External clients previously using TCP 6600 need the Unix socket instead.
- Snowflake keeps plain Python ahead of its science environment, as the user
  selected. The science environment stays available with `nix develop .#py-science`.
  Stable FFmpeg from the existing Noctalia plugin stays ahead of the moved
  unstable FFmpeg. Following the user's later Niri package removal, the global
  Quickshell command comes from the plain `qksh` development environment.
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

All ten focused checks and all 53 regression assertions passed after the startup
ownership cleanup. The earlier Niri package removal and priority-check update also
passed the full no-build evaluation using the Git-backed flake. No configuration
was activated.

After the NixOS consolidations, helper removals and package-file split, the
`module-evaluation`, `user-scripts`, `profile-priority`, `deadnix`, `statix` and
`formatting` checks passed, and the final no-build flake evaluation passed for
both hosts and canonical homes. The actual system UXPlay launcher also built
successfully, including its Bash syntax and ShellCheck checks; it was not run.

Regression fixtures cover Melal host overrides, private media paths, package-list
imports and service/hardware boundaries. Development fixtures additionally cover
bundled parent tools, default-off selections, independent DPP/Avalonia children,
Python-only output rooting and the actual minimal DPP shell. The host-module
split adds coverage for removed options, the battery optimization guard and
preserved per-host battery services/brightness keys. Startup fixtures cover merged
application commands and their ordering, independent application/autostart
opt-outs, and omission of the script when Niri is disabled. The updated result
contains 53 assertions.

The development regrouping deliberately adds C#, Python and Lua SDK/toolchains on
Rusty and JDK 21 on both hosts. Rusty's Yarn and Watchman are removed as requested;
Snowflake's Go and Rust selections now include gopls and rust-analyzer. Before/after
evaluation confirms all 15 existing project-shell derivations,
package inventories and hooks are identical. Both complete system objects,
accounts, state versions, 16 pinned inputs and runtime service settings match the
snapshot. Every retained application path keeps its original priority. Rusty
retains all 28 existing distinct development outputs and adds 13; Snowflake keeps
exactly the same 78. Only Yarn/Watchman and their generated completions are removed
from Rusty. The new SDKs, their runtime libraries and language-server paths are the only
distinct additions.

The commit-time follow-up on 2026-10-23 keeps the user's removal of `qmlgolsp` and
the separate `quickshell-niri` package from Niri's profile additions. Plain
Quickshell remains selected through the `qksh` development environment. Its
profile check now verifies that package identity, while FFmpeg and Python still
exercise competing package variants. This follow-up does not change project
shell definitions and is separate from the language-group comparison above.

The host-module split was compared with a pre-split snapshot carrying the same
concurrent user edits. Both complete system derivations and the normalized
architecture, battery, brightness, package, account and runtime settings match
exactly; all homes and 15 project shells remain unchanged. The concurrent package,
locale and bootloader edits are preserved separately from this refactor.

The startup ownership cleanup preserves every generated command, package path and
execution order. Rusty's script is byte-identical; Snowflake's has one additional
blank line between the Skwd and recorder blocks. Both complete system derivations,
package inventories/priorities, services and all 15 shells match the pre-cleanup
snapshot. The user's current Niri package/binding removals and explanatory theme
comments are preserved.

| Validation | Result |
| --- | --- |
| `nix flake check "path:$PWD" --no-build --no-write-lock-file` | Passed: both NixOS outputs, canonical homes, aliases, checks, shells and packages evaluate |
| `module-evaluation` | Built successfully; all 53 regression assertions pass, including startup merging/order/opt-outs, battery/brightness preservation, ordinary terminal/media/Fish host overrides, package imports, custom media paths, account preservation, hardware ownership and startup policies |
| `niri-config` | Built successfully; both canonical homes, disabled applications and Rusty with alternate Noctalia validate |
| `assets-setup`, `theme-switch` | Built successfully; local fixtures cover idempotence, selected-link preservation, backup collisions and failure handling |
| `shell-hooks`, `user-scripts` | Built successfully; development shell hooks, generated Fish/startup scripts and helper script syntax pass |
| `deadnix`, `statix` | Built successfully and final direct checks pass |
| Formatting | Full treefmt check built successfully; direct pinned `nixfmt --check` also passes for every Nix file |
| `profile-priority` | Built successfully; tiny buildEnv probes using actual profile metadata verify Python, FFmpeg and Quickshell command precedence without building those applications |
| System UXPlay launcher | Built successfully with Bash syntax and ShellCheck validation; no receiver or service was started |
| Development grouping | Comparison passed: only the approved SDK/language-tool additions and Rusty Yarn/Watchman removals; all 15 shells, existing development outputs and retained package priorities are preserved |
| `git diff --check` | Passed |
| Preservation checks | Original documents, lock, legacy assets and live links are unchanged; evaluated account fields match the pre-consolidation baseline |

The initial and migrated evaluated package sets were compared by store path.
The original migration retained existing application paths except generated
session-variable files, the duplicate system Home Manager CLI, and raw UXPlay now
referenced by its wrapper. The later requested development grouping also removes
Yarn and Watchman from Rusty and adds the SDKs/language tools described above.
Previously selected toolchain roots are all retained: 28 on Rusty and 78 on
Snowflake, plus HM's generated completion dependencies. The pinned
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
