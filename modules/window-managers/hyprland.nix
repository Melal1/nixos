{ pkgs, ... }: {



  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    swww
    wl-clipboard
    rofi-wayland
    waybar
  ];



}
