{
  pkgs,
  unstable,
  lib,
  ...
}:
let
  fromSystem = import ../lib/after-home-packages.nix lib;
in
{
  home.packages = fromSystem (
    (with pkgs; [

      ### ──────────────────────
      ###  CLI Utilities
      ### ──────────────────────
      jq
      lolcat
      figlet
      tmux
      unzip
      ripgrep
      fd
      tree
      bat
      eza
      fzf
      grc
      moreutils
      lsd
      tealdeer
      bc
    ])
    ++ (with unstable; [
      neovim
      herdr
      zip
      yt-dlp
      rar
      ffmpeg
    ])
  );
}
