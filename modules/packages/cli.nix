{ pkgs, unstable, config, ... }: {
  environment.systemPackages = (with pkgs; [

    ### ──────────────────────
    ###  CLI Utilities
    ### ──────────────────────
    libnotify
    mpc
    playerctl
    tmux
    vim
    unzip
    ripgrep
    fd
    tree
    zoxide
    fzf
    bat
    eza
    fastfetch
    clipse
    brightnessctl
    matugen
    fish
    starship
    moreutils
    yarn
    lsof
    lsd
    cmake
    gnumake
    premake
    yt-dlp
    claude-code
    wireguard-tools
    home-manager
    todoist
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
    slurp
    grim
    hyprpaper
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
    impala

  ])
  ++
  (with unstable; [
    neovim
    tree-sitter
    swww
  ]);
}

