{
  networking.networkmanager = {
    enable = true;
    # dns = "dnsmasq";
  };
  # services.dnsmasq.enable = true;

  services.openssh.enable = true;

  networking.wireguard.enable = true;
}
