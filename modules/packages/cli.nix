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
      clipse
      brightnessctl
      matugen

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
      wireguard-tools
      home-manager
      vdhcoapp
      bear
      tealdeer
      smassh

      ### ──────────────────────
      ###  Media & Graphics (CLI)
      ### ──────────────────────
      ffmpeg
      imagemagick
      cava
      grim
      hyprshot
      (ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      })
      zathura
      sioyek

      ### ──────────────────────
      ###  TUI
      ### ──────────────────────
      lazygit
      # Conditional btop depending on hostname
      (if config.networking.hostName == "alpha" then pkgs.btop-rocm else pkgs.btop)
      yazi
    ])
    ++
    (with unstable;
    [
      neovim
      tree-sitter
      swww
    ]);
}

