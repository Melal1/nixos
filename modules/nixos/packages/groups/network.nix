{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.my.groups.network.enable {
    environment.systemPackages = with pkgs; [
      protonvpn-gui nmap anydesk puddletag nmgui iw linux-wifi-hotspot
    ];
  };
}
