{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kitty # GPU-accelerated terminal emulator
    fish # Friendly interactive shell
    starship # Fast, customizable shell prompt
    waybar # Status bar for Wayland
    hyprpaper # Wallpaper manager for Hyprland
    eww # Custom widgets for the desktop
    wlogout # Logout menu for Wayland
    dunst # Lightweight notification daemon
    mpd # Music Player Daemon
    ncmpcpp # MPD client in the terminal
    brightnessctl # Control screen brightness
    matugen # Generate wallpapers based on material colors
    hyprpicker # Color picker for Wayland
  ];
}
