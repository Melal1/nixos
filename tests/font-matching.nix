# Exercise the host's generated font rules without reading the user's live config.
{ pkgs, host }:
let
  systemFonts = host.config.environment.etc.fonts.source;
  # Point the normal system configuration at its generated store directory
  # instead of the build machine's /etc. All font preferences remain untouched.
  fontsConf = pkgs.runCommand "font-matching-fonts.conf" { } ''
    substitute ${systemFonts}/fonts.conf "$out" \
      --replace-fail /etc/fonts/conf.d ${systemFonts}/conf.d
  '';
in
pkgs.runCommand "font-matching-check" { nativeBuildInputs = [ pkgs.fontconfig ]; } ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_DATA_HOME="$HOME/.local/share"
  export FONTCONFIG_FILE=${fontsConf}
  export FONTCONFIG_PATH=${systemFonts}
  mkdir -p "$XDG_CONFIG_HOME/fontconfig"

  expect_family() {
    actual=$(fc-match -f '%{family}' "$1")
    if [ "$actual" != "$2" ]; then
      printf 'Font fallback for %s: expected %s, got %s\n' "$1" "$2" "$actual" >&2
      exit 1
    fi
  }

  expect_family 'Arial:lang=ar:charset=0627' 'SF Arabic'
  expect_family 'Helvetica:lang=ar:charset=0627' 'SF Arabic'
  expect_family 'system-ui:lang=ar:charset=0627' 'SF Arabic'
  expect_family 'sans-serif:lang=ar' 'SF Pro Text'
  expect_family 'sans-serif:lang=ar:charset=0627' 'SF Arabic'
  expect_family 'emoji:charset=1f600' 'Twitter Color Emoji'
  touch "$out"
''
