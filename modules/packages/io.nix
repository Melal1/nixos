{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    openvpn         # VPN client
    iw              # Manage wireless devices
    acpi            # Show battery and thermal info
    linux-wifi-hotspot # Create Wi-Fi hotspots
    pavucontrol     # GUI audio control
  ];
}

