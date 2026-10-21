"""Inspect plugin state for Home Manager activation and noctalia-config-status."""

import argparse
import json
import os
import re
import sys
import tomllib
from pathlib import Path


def warning(message):
    use_color = (
        sys.stderr.isatty()
        and os.environ.get("TERM") != "dumb"
        and "NO_COLOR" not in os.environ
    )
    yellow = "\x1b[33m" if use_color else ""
    reset = "\x1b[0m" if use_color else ""
    print(f"{yellow}{message}{reset}", file=sys.stderr)


def key_name(parts):
    return ".".join(
        part if re.fullmatch(r"[A-Za-z0-9_-]+", part) else json.dumps(part)
        for part in parts
    )


def same_value(expected, saved, path):
    # Plugin ordering has no effect; GUI actions may reorder this list.
    if path == ("plugins", "enabled"):
        if not isinstance(saved, list) or not all(
            isinstance(plugin, str) for plugin in saved
        ):
            return False
        return set(expected) == set(saved)
    if path == ("plugin_settings", "raycursive/discord-voice", "discord_binary"):
        if isinstance(expected, str) and isinstance(saved, str):
            try:
                return Path(expected).expanduser().samefile(Path(saved).expanduser())
            except (OSError, ValueError):
                pass
    return expected == saved


def conflicts(expected, saved, path=()):
    differences = []
    for key, value in saved.items():
        if key not in expected:
            continue
        child_path = (*path, key)
        if isinstance(expected[key], dict) and isinstance(value, dict):
            differences.extend(conflicts(expected[key], value, child_path))
        elif not same_value(expected[key], value, child_path):
            differences.append(child_path)
    return differences


def warn_saved_overrides(expected, settings_path):
    try:
        with settings_path.open("rb") as settings_file:
            saved = tomllib.load(settings_file)
    except FileNotFoundError:
        return "missing"
    except (OSError, UnicodeError, tomllib.TOMLDecodeError) as error:
        warning(
            f"warning: Cannot inspect Noctalia GUI settings at {settings_path}: {error}"
        )
        return "unreadable"

    differences = conflicts(expected, saved)
    if not differences:
        return "matched"

    warning(
        "warning: Noctalia's saved GUI settings override Home Manager plugin values."
    )
    warning(f"  File: {settings_path}")
    for path in differences:
        warning(f"  Conflicting key: {key_name(path)}")

    if ("plugins", "enabled") in differences:
        selection = saved.get("plugins", {}).get("enabled")
        if isinstance(selection, list) and all(
            isinstance(plugin, str) for plugin in selection
        ):
            intended = set(expected["plugins"]["enabled"])
            actual = set(selection)
            for plugin in sorted(actual - intended):
                warning(
                    f"  Enabled by GUI but disabled in Nix: {json.dumps(plugin)}"
                )
            for plugin in sorted(intended - actual):
                warning(
                    f"  Enabled in Nix but disabled by GUI: {json.dumps(plugin)}"
                )

    warning(
        "  Saved settings are unchanged and still take precedence. Clear the listed"
    )
    warning("  overrides manually if these values should follow Home Manager.")
    return "conflicts"


def missing_plugins(manifest, state_dir):
    missing = []
    for plugin_id, source in sorted(manifest["sources"].items()):
        plugin_name = plugin_id.split("/", 1)[1]
        plugin_path = (
            state_dir
            / "plugins"
            / "materialized"
            / source
            / plugin_name
            / "plugin.toml"
        )
        if not plugin_path.is_file():
            missing.append((plugin_id, source, plugin_path))
    return missing


def report_status(manifest, state_dir, missing):
    print("Noctalia plugin configuration (applied Home Manager generation)")
    print(f"State directory: {state_dir}")
    print("\nEnabled by Home Manager:")
    enabled = manifest["config"]["plugins"]["enabled"]
    for plugin_id in sorted(enabled):
        print(f"  {plugin_id}")
    if not enabled:
        print("  (none)")

    print("\nMissing enabled plugin manifests:")
    for plugin_id, source, plugin_path in missing:
        print(f"  {plugin_id} (source: {source})")
        print(f"    Expected file: {plugin_path}")
    if not missing:
        print("  (none; plugin.toml exists for each enabled plugin)")

    settings_path = state_dir / "settings.toml"
    print(f"\nSaved GUI settings: {settings_path}", flush=True)
    result = warn_saved_overrides(manifest["config"], settings_path)
    summaries = {
        "missing": "  No saved GUI settings file.",
        "unreadable": "  Saved GUI settings could not be read; see warning.",
        "matched": "  No saved GUI overrides conflict with managed plugin values.",
        "conflicts": "  Conflicting saved GUI overrides found; see warnings.",
    }
    print(summaries[result], flush=True)


def main():
    parser = argparse.ArgumentParser(
        prog="noctalia-config-status",
        usage="%(prog)s [-h]",
        description=(
            "Show the applied Home Manager plugin selection, missing plugin "
            "manifests and conflicting saved GUI settings without changing files."
        ),
    )
    # The installed wrapper supplies the manifest and default state directory.
    parser.add_argument("manifest", type=Path, help=argparse.SUPPRESS)
    parser.add_argument("state_home", help=argparse.SUPPRESS)
    parser.add_argument("--status", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()

    with args.manifest.open(encoding="utf-8") as manifest_file:
        manifest = json.load(manifest_file)

    state_home = (
        os.environ.get("NOCTALIA_STATE_HOME")
        or os.environ.get("XDG_STATE_HOME")
        or args.state_home
    )
    state_dir = Path(state_home) / "noctalia"
    missing = missing_plugins(manifest, state_dir)

    if args.status:
        report_status(manifest, state_dir, missing)
        return

    warn_saved_overrides(manifest["config"], state_dir / "settings.toml")

    # Activation consumes only source names on stdout. Noctalia automatically
    # reconciles missing plugin files at startup, so refresh an existing session.
    for source in sorted({source for _, source, _ in missing}):
        print(source)


if __name__ == "__main__":
    main()
