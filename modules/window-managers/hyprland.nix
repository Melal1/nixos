{ pkgs, ... }: {



  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    swww
    wl-clipboard
    neofetch
    rofi-wayland
    waybar
  ];



}
