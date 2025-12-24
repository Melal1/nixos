#!/usr/bin/env python3

import curses
import os
import subprocess
from pathlib import Path

HOME = Path.home()

CACHE_DIR = HOME / ".cache" / "personal"
CMD_FILE = CACHE_DIR / "wallcmd"


# ---------- Helpers ----------


def run_cmd(cmd):
    """Run a shell command and return stdout as string."""
    try:
        out = subprocess.check_output(cmd, shell=True, text=True)
        return out.strip()
    except subprocess.CalledProcessError:
        return ""


def read_monitors():
    out = run_cmd("hyprctl monitors all | awk '/Monitor/ {print $2}'")
    return [line for line in out.splitlines() if line]


def list_images(dir_path: Path):
    pics = []
    for p in dir_path.iterdir():
        if p.is_file() and p.suffix.lower() in [
            ".png",
            ".jpg",
            ".jpeg",
            ".bmp",
            ".gif",
        ]:
            pics.append(p)
    return pics


# ---------- Ncurses Menu ----------


def menu(stdscr, title, options):
    curses.curs_set(0)
    highlight = 0

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, title)

        for i, opt in enumerate(options):
            if i == highlight:
                stdscr.addstr(i + 2, 0, opt, curses.A_REVERSE)
            else:
                stdscr.addstr(i + 2, 0, opt)

        key = stdscr.getch()

        if key in (ord("j"), ord("J")):
            highlight = (highlight + 1) % len(options)
        elif key in (ord("k"), ord("K")):
            highlight = (highlight - 1) % len(options)
        elif key == 10:  # Enter
            return highlight
        elif key in (ord("q"), ord("Q")):
            return -1


# ---------- Main Logic ----------


def main():
    import sys

    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <image_or_dir> [mode]")
        return 1

    input_path = Path(sys.argv[1]).resolve()
    mode = int(sys.argv[2]) if len(sys.argv) >= 3 else 0

    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    # ------------------------------------------------------------
    # MODE 3: path is **image file** → instantly set wallpaper
    # ------------------------------------------------------------
    if mode == 3:
        monitors = read_monitors()
        if not monitors:
            print("No monitors found.")
            return 1

        if not input_path.is_file():
            print("Mode 3 requires a direct image file path.")
            return 1

        selected = input_path
        print(f"Setting '{selected.name}' on all monitors...")

        monitor_cmds = {}

        for m in monitors:
            cmd = f'swww img -o "{m}" "{selected}" --transition-type grow  --transition-duration 1 --transition-step 30'
            os.system(cmd)
            monitor_cmds[m] = cmd

        # Save session
        with open(CMD_FILE, "w") as f:
            f.write("#!/usr/bin/env bash\n\n")
            for _, c in monitor_cmds.items():
                f.write(c + "\n")

        CMD_FILE.chmod(0o755)
        print("Session saved to", CMD_FILE)
        return 0

    # ------------------------------------------------------------
    # MODE 1: restore previous session
    # ------------------------------------------------------------
    if mode == 1:
        if CMD_FILE.exists() and CMD_FILE.stat().st_size > 0:
            print("Restoring last wallpaper session...")
            CMD_FILE.chmod(0o755)
            os.system(str(CMD_FILE))
        else:
            os.system(
                "dunstify 'Wallpaper' 'No previous wallpaper session found.\nRun wallSet first.' -u normal"
            )
        return 0

    # ------------------------------------------------------------

    # NORMAL MODE (directory + TUI selector)
    # ------------------------------------------------------------

    target_dir = input_path
    if not target_dir.is_dir():
        print("Error: input must be a directory unless using mode 3.")
        return 1

    edited_dir = target_dir / "edited"
    edited_dir.mkdir(parents=True, exist_ok=True)

    monitors = read_monitors()
    if not monitors:
        print("No monitors found.")
        return 1

    images = list_images(target_dir)
    if not images:
        print(f"No images found in {target_dir}")
        return 1

    rotation_labels = ["0°", "90°", "180°", "270°"]
    monitor_cmds = {}

    def curses_app(stdscr):
        while True:
            m_idx = menu(stdscr, "Select monitor:", monitors)
            if m_idx == -1:
                break

            img_names = [p.name for p in images]
            w_idx = menu(stdscr, "Select wallpaper:", img_names)
            if w_idx == -1:
                break

            r_idx = menu(stdscr, "Select rotation:", rotation_labels)
            if r_idx == -1:
                break

            rotate = r_idx * 90
            wallpaper = images[w_idx]
            final_wall = wallpaper

            if rotate != 0:
                final_wall = (
                    edited_dir / f"{wallpaper.stem}_rot{rotate}{wallpaper.suffix}"
                )
                subprocess.run(
                    f'magick "{wallpaper}" -rotate {rotate} "{final_wall}"', shell=True
                )

            cmd = f'swww img -o "{monitors[m_idx]}" "{final_wall}"'
            os.system(cmd)
            monitor_cmds[monitors[m_idx]] = cmd

            opt = menu(stdscr, "Options:", ["Set another", "Exit"])
            if opt == -1 or opt == 1:
                break

    curses.wrapper(curses_app)

    # Save session script
    with open(CMD_FILE, "w") as f:
        f.write("#!/usr/bin/env bash\n\n")
        for _, cmd in monitor_cmds.items():
            f.write(cmd + "\n")

    CMD_FILE.chmod(0o755)
    print(f"Session saved to {CMD_FILE}")

    return 0


if __name__ == "__main__":
    main()
