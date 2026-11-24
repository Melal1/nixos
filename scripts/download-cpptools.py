#!/usr/bin/env python3
"""Download the pinned cpptools VSIX in three resumable ranges, then import it."""

import concurrent.futures
import fcntl
import hashlib
import re
import signal
import subprocess
import sys
import threading
from pathlib import Path

URL = (
    "https://github.com/microsoft/vscode-cpptools/releases/download/"
    "v1.31.5/cpptools-linux-x64.vsix"
)
# Verified against Microsoft's release metadata and the pinned Nix source hash.
SIZE = 123811722
SHA256 = "e4be0faf0719fd0de0eaa942b0279bc777332d9543dac0eb0dff7d97d9e8a12a"
STORE_PATH = "/nix/store/xaldgldcvxmlkixvg1bjkpd22bghw1ly-ms-vscode-cpptools.vsix"
DIRECTORY = Path.home() / "Downloads" / "cpptools-1.31.5-linux-x64"
STOP = threading.Event()
ACTIVE = set()
ACTIVE_LOCK = threading.RLock()


def cancel(signum, frame):
    STOP.set()
    with ACTIVE_LOCK:
        for process in ACTIVE:
            if process.poll() is None:
                process.terminate()
    raise KeyboardInterrupt


def request(start, end, path):
    """Append a range, preserving valid partial responses when curl disconnects."""
    before = path.stat().st_size if path.exists() else 0
    headers = path.with_name(path.name + ".headers")
    with path.open("ab") as output:
        with ACTIVE_LOCK:
            if STOP.is_set():
                raise RuntimeError("Download cancelled")
            process = subprocess.Popen(
                [
                    "curl", "--http1.1", "--location", "--fail",
                    "--silent", "--show-error", "--connect-timeout", "20",
                    "--max-time", "180", "--header", "Accept-Encoding: identity",
                    "--max-filesize", str(max(end - start + 1, 65536)),
                    "--range", f"{start}-{end}", "--dump-header", str(headers), URL,
                ],
                stdout=output,
            )
            ACTIVE.add(process)
        try:
            code = process.wait()
        finally:
            with ACTIVE_LOCK:
                ACTIVE.discard(process)

    added = path.stat().st_size - before
    text = headers.read_text(errors="replace") if headers.exists() else ""
    status = re.findall(r"(?m)^HTTP/\S+\s+(\d{3})", text)
    final_headers = re.split(r"(?m)^HTTP/\S+\s+\d{3}[^\n]*\n", text)[-1]
    ranges = re.findall(
        r"(?im)^content-range:\s*bytes\s+(\d+)-(\d+)/(\d+)\s*$", final_headers
    )
    if status and status[-1] == "206" and ranges:
        actual_start, actual_end, total = map(int, ranges[-1])
        if actual_start == start and start <= actual_end <= end and added <= actual_end - start + 1:
            return total, added, code

    # Reject error pages and servers that ignore Range rather than appending them.
    with path.open("r+b") as output:
        output.truncate(before)
    if status and status[-1] == "200":
        raise RuntimeError("The download server ignored Range (HTTP 200); existing partial data was preserved")
    if code and not added:
        return None, 0, code
    raise RuntimeError("The server did not return the requested byte range")


def download_part(index, start, end, total):
    path = DIRECTORY / f"part-{index}"
    length = end - start + 1
    for attempt in range(1, 31):
        if STOP.is_set():
            raise RuntimeError("Download cancelled")
        have = path.stat().st_size if path.exists() else 0
        if have == length:
            return path
        if have > length:
            raise RuntimeError(f"Unexpected size for {path}; move it aside and rerun")
        size, added, code = request(start + have, end, path)
        if size is not None and size != total:
            raise RuntimeError("The remote file size changed during download")
        have += added
        print(f"Part {index + 1}: {have:,}/{length:,} bytes (attempt {attempt}, curl {code})", flush=True)
        if have == length:
            return path
        if STOP.wait(2):
            raise RuntimeError("Download cancelled")
    raise RuntimeError(f"Part {index + 1} still incomplete; rerun to resume it")


def verify(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    if digest.hexdigest() != SHA256:
        raise RuntimeError(f"SHA-256 mismatch for {path}; the file was not imported")


def main():
    DIRECTORY.mkdir(parents=True, exist_ok=True)
    with (DIRECTORY / ".lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        final = DIRECTORY / "ms-vscode-cpptools.vsix"
        if not final.exists():
            total = SIZE
            print(f"Downloading {total:,} bytes in three resumable parts to {DIRECTORY}", flush=True)
            width = (total + 2) // 3
            with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
                jobs = [pool.submit(download_part, i, i * width, min((i + 1) * width, total) - 1, total) for i in range(3)]
                try:
                    parts = [job.result() for job in jobs]
                except BaseException:
                    STOP.set()
                    with ACTIVE_LOCK:
                        for process in ACTIVE:
                            if process.poll() is None:
                                process.terminate()
                    raise
            combined = DIRECTORY / "combined.tmp"
            with combined.open("wb") as output:
                for path in parts:
                    with path.open("rb") as source:
                        for block in iter(lambda: source.read(1024 * 1024), b""):
                            output.write(block)
            verify(combined)
            combined.replace(final)
        verify(final)
        print("SHA-256 matches the pinned Nix source. Importing...", flush=True)
        imported = subprocess.check_output(
            ["nix", "store", "add", "--mode", "flat", "--name", final.name, str(final)], text=True
        ).strip()
        if imported != STORE_PATH:
            raise RuntimeError(f"Unexpected store path: {imported}")
        print(f"Ready: {imported}\nNow run: cd ~/.dotfiles/nixos && nh home switch", flush=True)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, cancel)
    signal.signal(signal.SIGTERM, cancel)
    try:
        main()
    except KeyboardInterrupt:
        print("\nCancelled. Downloaded parts are retained for the next run.", file=sys.stderr)
        sys.exit(130)
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
