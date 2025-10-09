{ pkgs, unstable, ... }: {
  environment.systemPackages = (with pkgs; [

    ### ──────────────────────
    ###  CLI Utilities
    ### ──────────────────────
    tmux # Terminal multiplexer
    vim # Fallback if my beatiful nvim setup failed 
    unzip # Extract .zip files
    ripgrep # Fast grep alternative
    fd # Simple, fast alternative to find
    tree # Directory tree viewer
    zoxide # Smart cd replacement
    fzf # Fuzzy finder
    bat # cat with syntax highlighting
    eza # Modern ls replacement
    fastfetch # System info fetcher
    clipse # Clipboard manager
    brightnessctl # Control screen brightness
    matugen # Generate wallpapers based on material colors
    fish # Friendly interactive shell
    starship # Fast, customizable shell prompt
    moreutils
    yarn
    lsof
    lsd
    cmake # Essintal for c/cpp projects and some nvim plugins build
    gnumake # Just in case
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
    ffmpeg # Audio/video converter
    imagemagick # Image manipulation tools
    cava # Terminal-based audio visualizer
    slurp # Select region on screen ( useful with grim)
    grim # Screenshot utility
    hyprpaper # Wallpaper manager for Hyprland
       (ncmpcpp.override {
          visualizerSupport = true;
          clockSupport = true;
        })
    zathura # Pdf viewer
    sioyek




    ### ──────────────────────
    ###  TUI
    ### ──────────────────────
    lazygit # TUI for Git
    btop # Res monitor
    yazi # File manager
    impala # Wifi Note make sure iwd is the network service not nm



  ])
  ++
  (with unstable; [
    neovim
    tree-sitter
    swww
  ]);

}

