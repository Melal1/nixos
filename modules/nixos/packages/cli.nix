{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  environment.systemPackages =
    (with pkgs; [

      ### ──────────────────────
      ###  CLI Utilities
      ### ──────────────────────
      libnotify
      xdg-user-dirs
      jq
      watchman
      speedtest-cli
      nmap
      iamb
      arp-scan
      delta
      lolcat
      figlet
      mpc
      playerctl
      tmux
      unzip
      ripgrep
      fd
      tree
      zoxide
      bat
      eza
      fastfetch
      fish
      fzf
      grc
      starship
      moreutils
      yarn
      lsof
      lsd
      home-manager
      bear
      tealdeer
      asciiquarium
      (ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      })
      lazygit
      yazi
    ])
    ++ (with unstable; [
      neovim
      herdr
      tree-sitter
      zip
      yt-dlp
      rar
      ffmpeg
      opencode
    ])
    ++ lib.optionals config.my.virtualisation.databaseEnabled [
      unstable.lazysql
      pkgs.pgmodeler
    ];
}
