{
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  # networking.wireless.iwd =
  #   {
  #     enable = true;
  #     settings = {
  #       Settings = {
  #         AutoConnect = false;
  #       };
  #     };
  #   };
  # networking.networkmanager.wifi.backend = "iwd";


  services.openssh.enable = true;
  services.resolved.enable = true;
}
