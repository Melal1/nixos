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
 #   apple-cursor
    bibata-cursors
    unoconv
    kdePackages.dolphin
    firefox
    # plasma5Packages.kdeconnect-kde
    nwg-displays # Handle displays 
  ];
   programs.kdeconnect.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      "zen-browser".packages.${pkgs.system}.default = prev."zen-browser".packages.${pkgs.system}.default.overrideAttrs (oldAttrs: rec {
        installPhase = ''
          mkdir -p $out/lib/zenbrowser
          cp ${./assets/mozilla.cfg} $out/lib/zenbrowser/mozilla.cfg
          mkdir -p $out/defaults/pref
          cp ${./assets/local-settings.js} $out/defaults/pref/local-settings.js
          ${oldAttrs.installPhase or ""}
        '';
      });
    })
  ];
}
