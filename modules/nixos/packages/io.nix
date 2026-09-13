{ pkgs, config, ... }: {

  environment.systemPackages =
    (with pkgs; [
      jmtpfs
      alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
      pavucontrol # GUI audio control
      android-tools
      easyeffects # Audio effects for PipeWire applications
    ])
    ++
    (
      if config.networking.hostName == "snowflake" then
        (with pkgs; [
        ])
      else if config.networking.hostName == "rusty" then
        (with pkgs; [
          acpi # Show battery and thermal info
          iw # Manage wireless devices
          linux-wifi-hotspot # Create Wi-Fi hotspots
        ])
      else
        [ ]
    );
}
