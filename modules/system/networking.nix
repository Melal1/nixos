{
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.settings.Settings.AutoConnect = true;
  networking.wireguard.enable = true;


  services.openssh.enable = true;
  services.resolved.enable = true;
}
