{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kitty # GPU-accelerated terminal emulator
    waybar # Status bar for Wayland
    eww # Custom widgets for the desktop
    wlogout # Logout menu for Wayland
    dunst # Lightweight notification daemon
    papirus-icon-theme
    hyprpicker # Color picker for Wayland
    # (discord.override {
    #   withVencord = true;
    # }) # Communication
    discord
    apple-cursor
    bibata-cursors
    unoconv
    kdePackages.dolphin
    firefox
    # plasma5Packages.kdeconnect-kde
    nwg-displays # Handle displays 
  ];
   programs.kdeconnect.enable = true;
}
