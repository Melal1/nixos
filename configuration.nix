{ config, lib, pkgs, ... }:


{


  # Enable CUPS to print documents.

  # services.libinput.enable = true;
  environment.systemPackages = with pkgs; [
    kitty
    #firefox
    # neovim 
    cargo
    python3
    nodejs
    go
    unzip
    ripgrep
    fd

    # Lsp
    clang
    clang-tools
    shellcheck
    shfmt
    nil
    nixpkgs-fmt
    lua-language-server
    stylua
    bash-language-server



    brightnessctl
    linux-wifi-hotspot
    vim
    iw
    acpi
    hyprpaper
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
    openvpn
    lazygit
    zoxide
    fzf
    fastfetch
    bat
    eza

    tree
  ];

}
