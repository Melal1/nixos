# Melal's Home Manager configuration

This is the single active Home Manager tree for Melal across hosts. `default.nix`
defines common defaults; `hosts/<host>/default.nix` selects packages and overrides
preferences for that machine. There is no top-level home tree.

Shared application and theme assets remain unchanged at their existing paths.
The distinct legacy Niri `programs/wm/niri/config.kdl` and Noctalia
`programs/noctalia/noctalia-config.toml` remain for active and rollback generations;
the former user TOML is retained for the same reason. New generations select
Niri's `session.kdl` and the host's Noctalia TOML instead. Do not delete old targets
until their references have been migrated and verified. This source migration
does not activate configurations or retarget runtime-owned links.
