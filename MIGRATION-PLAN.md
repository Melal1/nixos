# NixOS and Home Manager Migration Plan

This plan proposes a partial migration of the current repository. Writing this document does not authorize or execute configuration changes, builds, activation, or service operations.

Use [MIGRATION-PROMPT.md](MIGRATION-PROMPT.md) to instruct an implementation agent when you are ready. The background findings are in [ARCHITECTURE-AUDIT.md](ARCHITECTURE-AUDIT.md); the current repository and pinned sources take precedence if they have changed.

## Intended result

Keep the existing flake, host/user discovery, and standalone Home Manager workflow. Refine ownership so that:

- NixOS owns machines, accounts, permissions, networking, privileged integrations, and shared host services.
- Home Manager owns each user's applications, dotfiles, preferences, and selected user services.
- A user can share defaults between hosts and override them per host.
- Another user can reuse modules without inheriting Melal's identity, applications, or personal services.
- Existing features and startup policies remain available throughout the migration.

A feature can have both host and user responsibilities. Installing its application through Home Manager does not provide its system dependencies or grant privileges.

## Required clarification: UXPlay still needs system Avahi

**For this migration, UXPlay retains its existing Avahi-based discovery design. It requires Avahi to be enabled/configured in NixOS and the system Avahi daemon to be running when mirroring is used. The appropriate host firewall rules are also required.**

The split is:

| Responsibility | Owner |
|---|---|
| `services.avahi.enable`, publishing policy, service/socket definitions, and mDNS firewall policy | NixOS |
| Receiver TCP/UDP firewall openings | NixOS |
| UXPlay package, receiver arguments/configuration, and personal launcher | Home Manager |
| Optional UXPlay systemd user service, if chosen | Home Manager |
| Starting the shared system Avahi daemon | Host operation under the existing system policy |

The current configuration has `services.avahi.enable = true` when the mirroring feature is selected, but clears the service and socket `wantedBy` targets. Thus **declaratively enabled**, **started at boot**, and **currently running** are different states.

Preserve this manual-start policy unless the user explicitly requests a lifecycle change. With that policy, an administrator starts the system Avahi daemon before mirroring; installing UXPlay or starting its user service does not start Avahi automatically.

Additional constraints:

- UXPlay itself may run as a normal user application. It does not need to become a root system service.
- `publish.userServices = true` does not create a private Avahi service or restrict it to one user.
- A user unit's `Requires=` or `After=` cannot establish a dependency on a service in the system manager.
- Do not add `sudo`, a privileged activation script, or broad service-control permissions to bridge that boundary.
- Do not replace Avahi with another discovery method during this migration.
- If a launcher checks readiness, it should report the missing system dependency clearly and exit appropriately; it should not grant itself permission to start it.
- Distinguish configuration validation from runtime health. An assertion that Avahi is configured cannot establish that it is currently running.

The current host module is [modules/nixos/programs/ipad-screen-mirror.nix](modules/nixos/programs/ipad-screen-mirror.nix). It opens TCP/UDP ports 7000–7002 but supplies no UXPlay arguments or receiver configuration. Check for an existing user preference before selecting matching `-p 7000` behavior. Keep the receiver and firewall coordinated.

## Ownership to preserve or change

| Component | Plan |
|---|---|
| Hardware configuration, bootloader, kernel, drivers, filesystems, firmware | Retain in NixOS with independent host selections. |
| Accounts, login-shell registration, groups, udev, polkit, capabilities | Retain in NixOS. Review which user receives each grant. |
| NetworkManager, resolved, SSH, WireGuard configuration, firewall | Retain in NixOS. Do not treat installed network clients as configured services. |
| PipeWire/WirePlumber and desktop/session prerequisites | Retain the working NixOS baseline. NixOS may provision user services. |
| Steam/GameMode, nix-ld | Retain system integration. Personal preferences or ancillary tools can be user-owned. |
| MSSQL, Podman deployment, nix-serve, signing-key management | Retain current system ownership, storage, secrets, and manual startup policies. |
| Shared fonts | Keep current system scope initially. A personal font policy can be considered separately. |
| Personal CLI/GUI applications and editor tools | Move into reusable HM modules selected by each user. |
| Fish preferences, terminal selection, direnv | Use HM options directly where available; retain NixOS login-shell registration. |
| EasyEffects | Host supplies audio/dconf; HM supplies package, presets, and optional user service. |
| OBS | Move package/plugins to HM while preserving custom wrapping; keep device/kernel prerequisites in NixOS. |
| GPU Screen Recorder | Keep the privileged wrapper in NixOS; move user frontends/settings/startup where useful. |
| OpenRGB | Preserve NixOS hardware server plus independently selectable HM client. |
| QMK/Vial and Android webcam | Retain host rules/kernel support; move personal tools where practical. |
| Noctalia | Move shell package ownership to HM if useful; keep host networking/Bluetooth/power backends explicit. Preserve configuration and plugin behavior. |
| Skwd | Move to selected users' HM service if feasible with the pinned package; preserve its runtime model and environment. |
| MPD, ncmpcpp, playerctld, Nh cleanup | Retain in HM and correct shared runtime-resource assumptions. |
| Overlays, custom packages, development shells, checks | Retain shared flake infrastructure. Preserve package versions and overrides. |

## Minimal directory changes

Keep the current `hosts/`, `users/`, `modules/nixos/`, and `modules/home/` structure.

Add optional per-user host overrides:

```text
users/melal/
├── meta.nix
├── nixos.nix
├── home.nix
└── hosts/
    ├── rusty.nix
    └── snowflake.nix
```

- `users/melal/home.nix` imports reusable home modules and selects Melal's common preferences and applications.
- `users/melal/hosts/<host>.nix` contains that user's machine-specific selections and settings.
- `hosts/<host>/home.nix`, if retained, contains only intentional shared host defaults, not Melal's identity or plugin selections.
- `modules/home/` contains reusable definitions and a few package lists; introduce additional directories only when useful.
- True host-only system package additions can live directly in the host configuration.
- Keep `osConfig` reads for genuine host capabilities where useful; remove purely personal enable chains.
- Use existing NixOS/HM options before adding custom ones. Preserve custom options that bundle meaningful behavior.
- Import order is not an override mechanism. Use Nix module priorities deliberately.

## Migration sequence

### Phase 1: Confirm the baseline

Before editing configuration:

1. Read repository instructions, the audit, this plan, and the relevant pinned module sources.
2. Inspect current imports, conditions, package lists, feature settings, and Git status.
3. Record the two hosts and canonical homes: `rusty`, `snowflake`, `melal@rusty`, and `melal@snowflake`.
4. Identify existing uncommitted edits and preserve them. At plan creation these include `hosts/snowflake/home.nix`, `modules/nixos/packages/cli.nix`, and `modules/nixos/packages/snowflake/gui.nix`; recheck rather than assuming this list remains exhaustive.
5. Record manual-start services, disabled features, state versions, package provenance, and persistent state references.
6. Ask about material ambiguity before changing the affected behavior. Continue independent work where possible.

Deliverable: a short preservation checklist and any necessary clarification questions.

### Phase 2: Separate people from machines

1. Compose each home from the user's common module, optional shared host defaults, and optional user/host override.
2. Move Melal's Git identity and common application enables into the user configuration.
3. Move host-specific user selections, including Snowflake's plugins and browser setting, into the user/host override.
4. Make personal script values user-owned instead of universal reusable defaults.
5. Preserve all canonical output names and current single-user aliases.
6. Update the Fish Home Manager shortcut to target the canonical user/host output.
7. Preserve login-shell registration and grants in the NixOS account module.

Validate that both existing homes retain their intended behavior and that another evaluation-only user would not inherit Melal's identity or personal feature selections.

### Phase 3: Move ordinary applications and simplify shell ownership

1. Transfer personal CLI/GUI packages and editor tools to HM in small groups.
2. Preserve each host's stable/unstable package choices and package overrides.
3. Keep required administrative tools and privileged integrations in NixOS.
4. Replace redundant terminal enable bridges with the existing HM program options. Gate custom terminal files with their actual program option.
5. Move direnv/nix-direnv integration into HM and remove duplicate hook ownership.
6. Give shell helpers explicit runtime dependencies, or place them inside the feature that supplies those commands.
7. Resolve Rusty's browser mismatch using the user's intended browser.

Preserve currently available development commands for Melal when relocating them. Keep development shells and their hooks. Do not silently remove globally available SDKs or claim that installing shell package inputs also applies `shellHook` environments.

### Phase 4: Migrate application/service pairs separately

Work through UXPlay, EasyEffects, OBS, GPU Screen Recorder frontends, Noctalia, and optionally Skwd as distinct changes.

For each feature:

1. Identify the package, user configuration, runtime process, host prerequisite, permission requirements, and lifecycle.
2. Retain privileged configuration in NixOS and make the user portion independently selectable.
3. Choose one startup owner. Avoid duplicate Niri launches and user units.
4. Preserve package construction, environment, plugins, mutable links, and existing startup choices.
5. Validate both enabled and disabled configurations.

For UXPlay, apply the required system-Avahi policy above. Preserve manual receiver startup by default; an automatic UXPlay user service is optional and must not imply automatic Avahi startup.

When moving Noctalia, explicitly preserve its required host backends after removing system package ownership. Avoid two modules claiming `noctalia/config.toml`. Keep a single authoritative Skwd user unit if its ownership moves.

### Phase 5: Correct multiple-user and dependency assumptions

1. Replace shared MPD TCP/FIFO assumptions with supported per-user resources. Prefer socket-only operation if practical with the pinned modules; otherwise assign explicit distinct ports. Update ncmpcpp, mpc, and helpers together.
2. Use a per-user Kitty socket path with expansion supported by Kitty.
3. Make application startup checks user-specific, or use the user's service manager.
4. Keep hardware-specific monitor and audio-device settings in user/host overrides.
5. Validate that disabling one user's feature does not remove a capability needed by another user.
6. Keep account grants explicit. Per-user package installation does not make shared devices or host services private.
7. Remove unused enable layers or no-op settings only after identifying all consumers.

Do not assume systemd specifiers expand inside application configuration files; verify each consumer's path syntax.

### Phase 6: Validate and document the result

1. Extend existing evaluation checks to canonical user/host configurations.
2. Check package ownership, meaningful feature-disable combinations, and user isolation through evaluation-only fixtures where useful.
3. Verify system dependencies remain configured when user applications move.
4. Run focused evaluation first and relevant non-activating checks/builds as appropriate when implementation is authorized.
5. Preserve `flake.lock` and both state versions.
6. Document commands and file locations for future host/user additions, independent switches, and rollback.
7. Report actual validation results, anything unverified, and any user decisions still needed.

Evaluation can fetch inputs or trigger import-from-derivation; `--no-build` is not a guarantee of a purely read-only operation. Avoid unnecessary full builds and rebuilding CPU-optimised packages without a validation reason.

No live activation or runtime service changes are part of implementing this source migration. Runtime checks that require starting services or changing the live system must be left as instructions for the user unless separately authorized.

## Questions the implementation agent may ask

Ask only when current configuration or explicit preferences do not settle a material decision. Examples:

- Which browser should Rusty use: Firefox, LibreWolf, or another selection?
- Is a particular application intentionally available system-wide to all users?
- Does an existing external UXPlay configuration contain settings that must be preserved?
- Should a feature's startup behavior change, or should its current manual/automatic policy remain?
- Should currently global development toolchains remain available outside project shells?
- Is a proposed behavior or permission change intended, rather than merely a relocation?

Known defaults do not require repeated confirmation: keep standalone HM, retain current manual service policies, keep system Avahi as the UXPlay dependency, and preserve existing functionality.

## Completion criteria

- Both existing hosts and canonical home outputs remain available.
- Personal identities and selections are user-owned; hardware and system capabilities are host-owned.
- UXPlay's system Avahi/firewall dependency is explicitly documented and retained.
- Avahi remains manually started unless the user explicitly requests a change.
- Packages, service lifecycle, dependencies, permissions, and runtime resources have clear owners.
- Current data, secrets, mutable configuration, package overrides, and state versions are preserved.
- Relevant validation results and remaining runtime checks are reported honestly.
- No system activation, service operation, lock update, or unrelated work has been performed without separate authorization.

