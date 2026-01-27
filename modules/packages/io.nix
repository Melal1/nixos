{ pkgs,config, ... }: {
  # nixpkgs.config.permittedInsecurePackages = [
  #   "squid-6.10"
  # ];
  # services.squid.proxyPort = 8080;
  # services.squid.proxyAddress = "192.168.243.195";

  programs.adb.enable = true;

  environment.systemPackages = with pkgs; ([
    jmtpfs
  ])
  ++
  (if config.networking.hostName == "zeta" then
    (with pkgs; [
     iw # Manage wireless devices
     acpi # Show battery and thermal info
     linux-wifi-hotspot # Create Wi-Fi hotspots
    ])
  else if config.networking.hostName == "alpha" then
    (with pkgs; [
     alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
     easyeffects # Audio effects for PipeWire applications
     pavucontrol # GUI audio control
    ])
  else
    [ ]);
}
