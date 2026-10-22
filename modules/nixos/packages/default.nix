{ lib, pkgs, ... }:
{
  imports = [
    ./cache.nix
    ./fonts.nix
  ];
  options.my.packages.fonts.shared.enable = lib.mkEnableOption "the shared system font collection";

  # Available for system maintenance even without a personal profile.
  config.environment.systemPackages = with pkgs; [
    jq
    nmap
    arp-scan
    lsof
  ];
}
