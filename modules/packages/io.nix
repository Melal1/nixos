{ pkgs, config, ... }: {
  # nixpkgs.config.permittedInsecurePackages = [
  #   "squid-6.10"
  # ];
  # services.squid.proxyPort = 8080;
  # services.squid.proxyAddress = "192.168.243.195";

  programs.adb.enable = true;

  environment.systemPackages =
    (with pkgs; [
      jmtpfs
      alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
      pavucontrol # GUI audio control
      # squid
    ])
    ++
    (
      if config.networking.hostName == "alpha" then

        (with pkgs; [
          easyeffects # Audio effects for PipeWire applications
        ])
      else if config.networking.hostName == "zeta" then
        (with pkgs; [
          acpi # Show battery and thermal info
          iw # Manage wireless devices
          linux-wifi-hotspot # Create Wi-Fi hotspots
        ])
      else
        [ ]
    );


}
