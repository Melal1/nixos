{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [

      ### ──────────────────────
      ###  CLI Utilities
      ### ──────────────────────
      libnotify
      xdg-user-dirs
      jq
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
      fish
      fzf
      grc
      starship
      moreutils
      yarn
      lsof
      lsd
      cmake
      gnumake
      premake
      yt-dlp
      home-manager
      vdhcoapp
      bear
      tealdeer
      smassh
      ffmpeg
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
          imagemagick
          cava
          qpwgraph
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
      codex
      neovim
      tree-sitter
    ]);
}

# swww
# matugen
# grim
