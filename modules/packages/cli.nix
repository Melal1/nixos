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
    lf              # Terminal file manager
    zoxide          # Smart cd replacement
    fzf             # Fuzzy finder
    bat             # cat with syntax highlighting
    eza             # Modern ls replacement
    lazygit         # TUI for Git
    fastfetch       # System info fetcher

    ### ──────────────────────
    ###  Media & Graphics (CLI)
    ### ──────────────────────
    ffmpeg          # Audio/video converter
    imagemagick     # Image manipulation tools
    cava            # Terminal-based audio visualizer
  ];
}

