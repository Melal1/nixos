{ pkgs, ... }: {
  # nixpkgs.config.permittedInsecurePackages = [
  #   "squid-6.10"
  # ];
  # services.squid.proxyPort = 8080;
  # services.squid.proxyAddress = "192.168.243.195";

  environment.systemPackages = with pkgs; [
    openvpn # VPN client
    iw # Manage wireless devices
    acpi # Show battery and thermal info
    linux-wifi-hotspot # Create Wi-Fi hotspots
    alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
    easyeffects # Audio effects for PipeWire applications
    pavucontrol # GUI audio control
    # squid
  ];
}
