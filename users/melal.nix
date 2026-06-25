{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.melal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "adbusers" "uinput" ]; # Wheel enables sudo 
    description = "Melal user";
    home = "/home/melal";
    shell = pkgs.fish;
  };
}
