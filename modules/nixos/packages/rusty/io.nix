{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.io.host.enable {
    environment.systemPackages = with pkgs; [
      acpi
      iw
      linux-wifi-hotspot
    ];
  };
}
