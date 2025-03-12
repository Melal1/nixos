{ config, lib, pkgs, ... }:


{



  # Enable CUPS to print documents.

  # services.libinput.enable = true;
  environment.systemPackages = with pkgs; [
    #kitty
    #firefox
    go
    gcc
    cargo
    python3
    nodejs
    acpi
    fish
    starship
    yazi
    mpd
    ncmpcpp
    eww
    waybar
    home-manager
    dunst
    pavucontrol

    unzip # Nvim
    ripgrep # Nvim
    fd # Nvim
    tree
    #tailscale restricted on my fking country 
    #wireguard 
  ];

}
