{ pkgs, unstable, config, ... }: {
  environment.systemPackages =
    (with pkgs; [

      ### ──────────────────────
      ###  CLI Utilities
      ### ──────────────────────
      libnotify
      jq
      lolcat
      timer
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
      yt-dlp
      home-manager
      vdhcoapp
      bear
      tealdeer
      smassh

      ### ──────────────────────
      ###  Media & Graphics (CLI)
      ### ──────────────────────
      (ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      })
      sioyek

      ### ──────────────────────
      ###  TUI
      ### ──────────────────────
      lazygit
      # Conditional btop depending on hostname
      yazi
      cava
    ]) ++

    (with unstable;
    [
      neovim
      tree-sitter
    ]) ++

    (if config.networking.hostName == "zeta" then
      (with pkgs; [
        btop
        brightnessctl
      ])
    else if config.networking.hostName == "alpha" then
      (with pkgs; [
        btop-rocm
        ffmpeg
        imagemagick
        premake
      ])
    else
      [ ]);
}
