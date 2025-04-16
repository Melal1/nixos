{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.melal = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Wheel enables sudo 
    description = "Melal user";
    home = "/home/melal";
    shell = pkgs.fish;
  };
}
