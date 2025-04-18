{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kitty           # GPU-accelerated terminal emulator
    waybar          # Status bar for Wayland
    eww             # Custom widgets for the desktop
    wlogout         # Logout menu for Wayland
    dunst           # Lightweight notification daemon
    hyprpicker      # Color picker for Wayland
    discord         # Communication 
  ];
}

