{ user }:
{ lib, ... }:
{
  # Default to the same shell selected for the NixOS user account.
  programs.${user.shell}.enable = lib.mkDefault true;

  home = {
    username = user.name;
    inherit (user) homeDirectory;
    stateVersion = user.homeStateVersion;
  };
}
