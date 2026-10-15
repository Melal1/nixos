# Recovering a failed Nix source download

This guide explains how to download a file in parallel sections, verify it, and
import it into the Nix store so an existing build can continue. The worked example
is `ms-vscode.cpptools` version `1.31.5`, whose Marketplace download failed with
HTTP/2 errors on Snowflake.

The package version, expected checksum, and flake lock file stay the same.

Run the commands in the same Bash terminal unless a step says otherwise. The
example requires Bash, curl, Python 3, GNU coreutils, and Nix with `nix-command`
and `flakes` enabled, as they are in this configuration.

## 1. Identify the failed source download

Find the first actual builder failure in the rebuild output. Other errors can be
dependencies failing because that one download failed.

For this example, the failed source derivation was:

```bash
failed_drv=/nix/store/v2wvn7n2ghrhp2b2b2pvsfi828zgh7ap-ms-vscode-cpptools.vsix.drv
nix log "$failed_drv"
nix derivation show "$failed_drv"
```

The derivation revealed these values:

| Field | Value |
| --- | --- |
| Source filename | `ms-vscode-cpptools.vsix` |
| Extension version | `1.31.5` |
| Expected SHA-256 | `sha256-5L4PrwcZ/Q3g6qlCsCebx3czLZVD2sDrDf99l9nooSo=` |
| Expected source path | `/nix/store/xaldgldcvxmlkixvg1bjkpd22bghw1ly-ms-vscode-cpptools.vsix` |

In the JSON, look for `name`, `urls`, `outputHash`, and the output path. Depending
on the Nix version, fetcher settings can appear under `structuredAttrs` or `env`.

These values belong to this exact package revision. For another failed download,
read its own derivation rather than reusing this example's filename or checksum.

## 2. Find an identical official download

Microsoft also publishes the VSIX archive in its
[official GitHub release](https://github.com/microsoft/vscode-cpptools/releases/tag/v1.31.5).
The GitHub filename differs from Nix's source filename, but the file contents have
the same expected SHA-256 hash.

Create a working directory outside the repository and Nix store:

```bash
download_dir="$HOME/.cache/nix-downloads/cpptools-1.31.5"
mkdir -p "$download_dir"
cd "$download_dir"

download_url='https://github.com/microsoft/vscode-cpptools/releases/download/v1.31.5/cpptools-linux-x64.vsix'
archive_name='ms-vscode-cpptools.vsix'
expected_hash='sha256-5L4PrwcZ/Q3g6qlCsCebx3czLZVD2sDrDf99l9nooSo='
```

The final checksum check determines whether the alternate download is usable.
Matching version numbers alone are insufficient.

## 3. Get the total size in bytes

One option is to request HTTP headers without downloading the file:

```bash
curl --http1.1 --head --location --fail "$download_url"
```

Look for `Content-Length` in the final response after redirects:

```http
Content-Length: 123811722
```

Some servers reject `HEAD` requests or omit the size. If the server supports
ranges, request one byte and inspect the response headers instead:

```bash
curl --http1.1 --location --fail --range 0-0 \
  --dump-header - --output /dev/null "$download_url"
```

For a server honoring the request, the final response looks like:

```http
HTTP/1.1 206 Partial Content
Content-Range: bytes 0-0/123811722
Content-Length: 1
```

Here, the number after `/` is the whole file's size. `Content-Length: 1` describes
only the requested one-byte response. A server ignoring the range may return
`200 OK` and send the whole file instead.

For the actual recovery, the exact size came from GitHub's release metadata:

```bash
curl --http1.1 --location --fail --silent --show-error \
  'https://api.github.com/repos/microsoft/vscode-cpptools/releases/tags/v1.31.5' \
  | python3 -c '
import json, sys
release = json.load(sys.stdin)
asset = next(a for a in release["assets"] if a["name"] == "cpptools-linux-x64.vsix")
print("Bytes:", asset["size"])
print("SHA-256:", asset.get("digest"))
print("URL:", asset["browser_download_url"])
'
```

That release reported `123811722` bytes. Use the exact byte count, rather than a
rounded display such as “118 MB.”

## 4. Calculate the byte ranges

Choose eight pieces and divide the total size by eight, rounding up:

```bash
total=123811722
pieces=8
chunk=$(( (total + pieces - 1) / pieces ))
printf 'Bytes per full piece: %s\n' "$chunk"
```

The result is `15476466` bytes per full piece. The integer-arithmetic expression
`(total + pieces - 1) / pieces` performs division rounded up.

For each piece, numbered from zero:

```text
start = piece_number × chunk
end   = min(start + chunk, total) − 1
```

Byte positions start at zero and both range endpoints are included. A ten-byte
file occupies positions `0` through `9`, so the last position is `total - 1`.

`min()` prevents the final piece from extending beyond the file. For example,
splitting ten bytes into three pieces gives a rounded-up chunk size of four:
`0–3`, `4–7`, and `8–9`. The last piece contains only two bytes.

For the VSIX archive, all eight ranges are:

| Piece | Start | End |
| --- | ---: | ---: |
| 0 | 0 | 15476465 |
| 1 | 15476466 | 30952931 |
| 2 | 30952932 | 46429397 |
| 3 | 46429398 | 61905863 |
| 4 | 61905864 | 77382329 |
| 5 | 77382330 | 92858795 |
| 6 | 92858796 | 108335261 |
| 7 | 108335262 | 123811721 |

## 5. Download the pieces in parallel

Optional illustration: a single section can be downloaded with this command.
Skip it if you are going to run the complete download block below.

```bash
curl --http1.1 --location --fail \
  --range 15476466-30952931 \
  "$download_url" -o part1
```

This is an illustration; the complete script below stores its pieces under
`parts/` instead. If you ran the illustration, you can remove `part1` afterward.

| Argument | Purpose |
| --- | --- |
| `--http1.1` | Use HTTP/1.1, avoiding the HTTP/2 failures from the original attempt. |
| `--location` | Follow redirects to the actual download server. |
| `--fail` | Exit with an error for HTTP error responses such as 404. |
| `--range START-END` | Request only those bytes, including both endpoints. |
| `"$download_url"` | Expand the variable containing the download URL. |
| `-o part1` | Save the bytes as a local file named `part1`. |
| `\` at the end of a line | Continue the shell command on the next line. |

Download all eight pieces with this Bash block. Each background job checks its
piece's length, and the parent waits for every job and reports failures:

```bash
(
  set -euo pipefail
  mkdir -p parts
  download_pids=()

  for ((piece = 0; piece < pieces; piece++)); do
    start=$(( piece * chunk ))
    end=$(( start + chunk - 1 ))
    if (( end >= total )); then
      end=$(( total - 1 ))
    fi
    part="parts/part$piece"
    expected_size=$(( end - start + 1 ))

    (
      # Reuse completed pieces when this block is rerun.
      if [[ ! -f "$part" ]] || [[ $(stat -c %s "$part") != "$expected_size" ]]; then
        curl --http1.1 --location --fail --silent --show-error \
          --retry 3 --retry-all-errors \
          --connect-timeout 20 --max-time 900 \
          --range "$start-$end" "$download_url" -o "$part"
      fi

      actual_size=$(stat -c %s "$part")
      if [[ "$actual_size" != "$expected_size" ]]; then
        printf 'Part %s: expected %s bytes, got %s\n' \
          "$piece" "$expected_size" "$actual_size" >&2
        exit 1
      fi
      printf 'Completed part%s\n' "$piece"
    ) &
    download_pids+=("$!")
  done

  failed=0
  for download_pid in "${download_pids[@]}"; do
    if ! wait "$download_pid"; then
      failed=1
    fi
  done
  if (( failed )); then
    printf 'Some pieces failed. Rerun this block before continuing.\n' >&2
    exit 1
  fi
)
```

The `&` starts each job in the background, allowing the requests to run together.
`$!` records each job's process ID, and `wait` waits for that job to finish.

The timeout allows 15 minutes per attempt; the shorter five-minute timeout used
during the initial recovery was insufficient for the slow connection. This
example reuses complete pieces but downloads incomplete pieces again on rerun.
The actual recovery also resumed partial pieces by requesting their missing tails.

Use a fresh working directory when changing the URL, version, or file size.
Piece lengths alone do not establish that their contents are correct; step 7
checks the complete file's hash.

## 6. Join the pieces in their original order

After every download succeeds:

```bash
cat parts/part{0..7} > "$archive_name"
stat -c '%s bytes' "$archive_name"
```

Bash expands `part{0..7}` to `part0 part1 ... part7`, in that order. The result
must be `123811722` bytes. Joining simply puts the raw bytes next to each other;
the individual sections are not independently usable archives.

## 7. Verify the complete file

```bash
actual_hash=$(nix hash file --type sha256 --sri "$archive_name")
printf 'Expected: %s\nActual:   %s\n' "$expected_hash" "$actual_hash"
```

Both lines must contain:

```text
sha256-5L4PrwcZ/Q3g6qlCsCebx3czLZVD2sDrDf99l9nooSo=
```

If they differ, stop and check the URL, ranges, piece lengths, and concatenation
order. Keep the package's original expected hash; it identifies the file the
existing build requires. The next command also enforces that hash independently.

## 8. Import the verified archive into the Nix store

```bash
nix store prefetch-file \
  --name "$archive_name" \
  --expected-hash "$expected_hash" \
  "file://$PWD/$archive_name"
```

`file://` tells Nix to read the already downloaded local file. Nix verifies the
expected hash, copies the file into the store, and registers it in its database.
No manual copying into `/nix/store` is needed, and this command does not require
sudo on this NixOS installation.

`--name` preserves the source filename expected by the original derivation, even
though the GitHub release used a different filename. For this flat, fixed-output
source with the same name and checksum, Nix produces the exact requested path:

```text
/nix/store/xaldgldcvxmlkixvg1bjkpd22bghw1ly-ms-vscode-cpptools.vsix
```

The original fetch derivation can now reuse that valid output without downloading
it from the Marketplace.

This procedure applies directly to this ordinary file fetch. Fetchers that unpack
archives or transform files can require a different import method and hash mode.

## 9. Build the original package and retry the system rebuild

From the configuration repository, build the original package to confirm it can
use the imported source:

```bash
cd ~/.dotfiles/nixos
nix build --impure --no-write-lock-file --no-link --print-out-paths --expr \
  '(builtins.getFlake (toString ./.)).nixosConfigurations.snowflake.pkgs.vscode-extensions.ms-vscode.cpptools'
```

Nix unpacks the imported VSIX, applies the package's existing patches, and creates
the finished extension in its own output path. The successful recovery produced:

```text
/nix/store/f53gqh7h43hdd75d7pdh7x23c524kfqc-vscode-extension-ms-vscode-cpptools-1.31.5
```

Retry the system rebuild:

```bash
nh os switch
```

Or use the underlying NixOS command:

```bash
sudo nixos-rebuild switch --flake .#snowflake
```

The rebuild reuses the completed extension and other valid store outputs. Other
packages still needed by the new system can download or build as usual.

## 10. Remove the temporary download files

After the package builds successfully, the working copies can be removed. Nix
already has the imported source and built package:

```bash
cd "$download_dir"
rm -- "$archive_name" parts/part{0..7}
rmdir parts
```

## References

- [curl command-line reference](https://curl.se/docs/manpage.html): HTTP versions, redirects, headers, and byte ranges.
- [Nix `store prefetch-file` reference](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-store-prefetch-file): local-file imports, expected hashes, and store filenames.
- [Microsoft C/C++ extension release v1.31.5](https://github.com/microsoft/vscode-cpptools/releases/tag/v1.31.5): the alternate official archive used in this recovery.
