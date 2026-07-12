{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [

      ### ──────────────────────
      ###  CLI Utilities
      ### ──────────────────────
      libnotify
      xdg-user-dirs
      jq
      speedtest-cli
      nmap
      arp-scan
      discord
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
      if config.networking.hostName == "alpha" then

        (with pkgs; [
          btop-rocm
          nmap
          imagemagick
          cava
          ninja
          qpwgraph
        ])
        ++ (with unstable;[
          opencode
          codex
        ])
      else if config.networking.hostName == "zeta" then
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
      timr-tui
      dooit
      neovim
      tree-sitter
      zip
      yt-dlp
      rar
      geminicommit
      ffmpeg
    ]);
}
