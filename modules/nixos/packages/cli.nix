{ pkgs, unstable, config, ... }: {
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
      arp-scan
      delta
      lolcat
      figlet
      timer
      browsh
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
      codex
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
      smassh
      asciiquarium
      (ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      })
      lazygit
      yazi
    ])
    ++
    (
      if config.networking.hostName == "snowflake" then

        (with pkgs; [
          btop-rocm
          nmap
          imagemagick
          cava
          ninja
          qpwgraph
        ])
        ++ (with unstable;[
          codex
        ])
      else if config.networking.hostName == "rusty" then
        (with pkgs; [
          btop
          brightnessctl
        ])
      else
        [ ]
    )
    ++
    (with unstable;
    [
      spotdl
      timr-tui
      neovim
      herdr
      tree-sitter
      zip
      yt-dlp
      rar
      geminicommit
      ffmpeg
      opencode
    ]);
}
