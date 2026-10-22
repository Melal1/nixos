# Migration Implementation Prompt

Use this prompt when you want an agent to implement the migration. Creating or reading this file alone does not authorize implementation.

---

You are an experienced NixOS and Home Manager engineer working in `/home/melal/.dotfiles/nixos`.

When I ask you to execute this prompt, implement the partial migration described below and in `MIGRATION-PLAN.md`. Use `ARCHITECTURE-AUDIT.md` as background, but verify the current repository and option semantics against the versions pinned in `flake.lock`.

## Ask questions when needed

You may ask me questions at any point if something is unclear, incomplete, contradictory, or would materially affect behavior.

- Ask concise, specific questions before making a consequential assumption.
- Explain the decision and, when helpful, give a recommended default.
- Continue independent work while waiting, but leave work that depends on my answer pending.
- Do not interpret silence as approval.
- Do not repeatedly ask about decisions already made in this prompt or the current conversation.
- Resolve routine implementation details yourself where they preserve established behavior.

For example, ask if the intended Rusty browser cannot be established, an application may intentionally be shared system-wide, an external UXPlay configuration needs preservation, or a proposed change would alter startup, permissions, or development workflows.

## Scope and limits

Implement a practical cleanup of ownership while preserving functionality:

- Keep the current flake, host/user discovery, and standalone Home Manager workflow.
- Keep both NixOS hosts, `rusty` and `snowflake`.
- Keep canonical homes `melal@rusty` and `melal@snowflake` and the current single-user aliases.
- Do not switch Home Manager to the NixOS module during this migration.
- Preserve `flake.lock`, `system.stateVersion`, and `home.stateVersion`.
- Preserve stable/unstable selections, package overrides, CPU optimisation choices, and required output rooting.
- Preserve existing user data, database volumes, secret references, mutable theme links, and external configuration repositories.
- Preserve existing feature availability and manual/automatic startup policies unless I explicitly request a behavior change.

Source edits and relevant non-activating validation are in scope once I ask you to execute this prompt. Do not run `nixos-rebuild switch/test/boot`, `home-manager switch`, activation scripts, live service start/stop/enable operations, or other live-system changes. Do not update inputs, migrate database storage, change account privileges, commit, push, or perform unrelated cleanup without separate authorization.

Inspect Git status and existing diffs before editing. Preserve my uncommitted work; do not revert or overwrite it.

## Required UXPlay and system-service boundary

**For this migration, UXPlay uses the existing Avahi-based discovery setup. It requires system Avahi to be enabled/configured in NixOS and the system daemon to be running when mirroring is used. The host firewall configuration is also required.**

Moving UXPlay's package or configuration into Home Manager does not remove those host dependencies.

Keep these responsibilities separate:

- **NixOS:** Avahi account/service/socket, system D-Bus integration, publishing policy, mDNS access, and receiver firewall rules.
- **Home Manager:** UXPlay package, receiver settings/arguments, user launcher, and an optional systemd user service if appropriate.
- **Host lifecycle:** Avahi startup remains a system operation governed by the existing manual-start policy.

The current `modules/nixos/programs/ipad-screen-mirror.nix` sets `services.avahi.enable = true` through its feature condition, and clears the service/socket `wantedBy` targets. Preserve that manual-start behavior. Do not silently enable Avahi at boot or change its activation policy.

Explicitly distinguish:

1. A service configured declaratively with `enable = true`.
2. A service selected to start at boot.
3. A service currently running.

Do not:

- Replace Avahi with a private user daemon or an alternative discovery method.
- Claim `publish.userServices` means per-user Avahi isolation.
- Claim UXPlay itself must run as root.
- Add `sudo` to HM activation or user units to start Avahi.
- Add broad privileges to let an application manage the system daemon.
- Use `Requires=avahi-daemon.service` or `After=avahi-daemon.service` in a user unit as if they refer to the system manager.

Keep manual UXPlay launch as the default. If a launcher performs a readiness check, make it report the missing system dependency clearly; it must not start privileged services.

Coordinate receiver ports with the host firewall. The current host opens TCP/UDP 7000–7002 but the repository supplies no matching receiver arguments. Check for existing preferences before choosing `-p 7000` or equivalent supported receiver configuration. Do not expose any credentials from external receiver configuration.

If more than one user runs UXPlay simultaneously, account for distinct ports and receiver identities. Do not build a multi-instance framework unless actually needed.

Apply the same reasoning to every other feature: package installation, execution under a user account, a systemd user service, a system service with `User=`, and per-user access restrictions are different things.

## Ownership decisions

Retain these in NixOS:

- Hardware, bootloader, kernels, drivers, firmware, filesystems, and kernel settings.
- Accounts, login-shell registration, group membership, device permissions, udev, polkit, and capability wrappers.
- Host networking, DNS, SSH, firewall, Avahi, and other system services.
- Working PipeWire/WirePlumber and Niri/Ly session prerequisites, including needed portal/PAM integration.
- Steam/GameMode system integration and nix-ld.
- The current MSSQL/Podman deployment, nix-serve, and signing-key management.
- Existing shared fonts initially.

Move personal applications, editor tools, shell preferences, and application configuration into Home Manager where technically appropriate.

Preserve deliberate splits:

- OpenRGB hardware server in NixOS; selected users' clients in HM.
- GPU Screen Recorder's privileged wrapper in NixOS; user frontends/configuration/startup in HM where useful.
- Android webcam and QMK host support in NixOS; personal tools in HM.
- EasyEffects audio/dconf prerequisites in NixOS; app/presets/optional user service in HM.
- OBS app/plugins in HM where supported; kernel/device prerequisites in NixOS.
- Noctalia shell/config/plugins in HM where useful; required networking, Bluetooth, and power backends remain explicit host capabilities.
- Skwd may move from a globally distributed user unit to selected users' HM units, preserving its runtime model and environment.

Do not move services merely to follow a naming convention. A NixOS module can correctly configure a user daemon.

## Implementation sequence

Follow `MIGRATION-PLAN.md` in incremental, reviewable changes:

1. Confirm active imports, current outputs, enabled/disabled features, startup policies, and pinned option definitions.
2. Compose homes from reusable modules, user defaults, and optional user/host overrides.
3. Move Melal's identity/common selections into `users/melal/home.nix` and machine-specific personal settings into `users/melal/hosts/<host>.nix`.
4. Keep `hosts/<host>/home.nix` only for intentional shared host defaults if it remains useful.
5. Update shortcuts and checks to canonical `user@host` outputs.
6. Move ordinary personal packages in small groups, preserving package provenance and dependencies.
7. Simplify terminal enable chains using existing HM options. Move direnv integration and remove duplicate hook ownership.
8. Migrate each application/service pair separately, retaining host prerequisites and one startup owner.
9. Correct MPD's shared TCP/FIFO assumptions, Kitty's shared socket path, unscoped process checks, and missing script dependencies.
10. Update documentation and relevant checks; remove obsolete definitions only after identifying their consumers.

Preserve the existing development shells and their environment hooks. Moving their package inputs into `home.packages` does not activate `shellHook` settings. Preserve Melal's currently available development commands; ask before removing globally available SDKs or changing workflows.

Prefer per-user sockets/runtime paths when supported by the pinned modules. If socket-only MPD operation is not practical, select explicit distinct ports and keep clients/helpers consistent. Verify path expansion for the actual consumer; systemd specifiers do not automatically expand in application configuration files.

Retain one-way `osConfig` reads for genuine host capabilities where helpful. Remove unnecessary personal enable chains, and avoid reverse inference of privileged host settings from users' package lists.

Keep abstractions small. Use upstream options where sufficient. Verify module merging priorities rather than treating import order as an override mechanism. Do not invent upstream options.

## Validation

Reuse and adapt the existing checks. Add only meaningful coverage needed for the changed architecture.

Verify:

- Both NixOS configurations and canonical homes evaluate.
- Existing single-user aliases are preserved.
- Personal packages/configuration have the intended owners.
- Disabled user features stop contributing their configuration and user services.
- Another evaluation-only user does not inherit Melal's identity or personal feature selections.
- Host capabilities remain available independently of one user's selections.
- UXPlay retains its system Avahi/firewall dependency and manual-start policy.
- Receiver and firewall ports agree.
- MPD, ncmpcpp, mpc, and visualizer paths agree.
- Niri bindings, browser selection, script commands, package overrides, and startup behavior remain coherent.
- Only one service/startup declaration owns each process.

Start with focused evaluations, using `--no-write-lock-file` where supported. Run relevant existing checks and non-activating builds as appropriate. Evaluation may fetch inputs or trigger import-from-derivation; do not describe `--no-build` as a guarantee of no downloads or store writes. Avoid unnecessary broad builds, especially CPU-optimised packages.

Do not introduce a real additional account into host configurations just to test multiple-user composition; use evaluation-only fixtures if needed.

If validation is blocked, report the exact limitation. Do not claim that evaluation proves runtime availability, hardware operation, or active Avahi discovery. Leave live-system validation as explicit user instructions unless separately authorized.

## Completion report

Provide:

- What changed, why, and the principal files involved.
- The final host/user ownership and import flow.
- A clear statement that UXPlay still needs the system Avahi daemon running and the NixOS firewall rules.
- Actual validation results and any unresolved questions or unverified runtime behavior.
- Any changed command, path, startup behavior, or compatibility alias.
- A short, staged activation/rollback procedure for me to review, without executing it.

Stop after source changes, documentation, and non-activating validation are complete. Leave system activation and runtime service operations to me unless I authorize them separately.

