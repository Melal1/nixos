{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [

    ### ──────────────────────
    ###  CLI Utilities
    ### ──────────────────────
    tmux            # Terminal multiplexer
    unzip           # Extract .zip files
    ripgrep         # Fast grep alternative
    fd              # Simple, fast alternative to find
    tree            # Directory tree viewer
    zoxide          # Smart cd replacement
    fzf             # Fuzzy finder
    bat             # cat with syntax highlighting
    eza             # Modern ls replacement
    fastfetch       # System info fetcher
    clipse          # Clipboard manager
    brightnessctl   # Control screen brightness
    mpd             # Music Player Daemon
    matugen         # Generate wallpapers based on material colors
    fish            # Friendly interactive shell
    starship        # Fast, customizable shell prompt
    neovim          # Best Editor 


    ### ──────────────────────
    ###  Media & Graphics (CLI)
    ### ──────────────────────
    ffmpeg          # Audio/video converter
    imagemagick     # Image manipulation tools
    cava            # Terminal-based audio visualizer
    slurp           # Select region on screen ( useful with grim)
    grim            # Screenshot utility
    hyprpaper       # Wallpaper manager for Hyprland
    ncmpcpp         # MPD client in the terminal
    zathura         # Pdf viewer



    ### ──────────────────────
    ###  TUI
    ### ──────────────────────
    lazygit         # TUI for Git
    btop            # Res monitor
    yazi            # File manager



  ];
}

