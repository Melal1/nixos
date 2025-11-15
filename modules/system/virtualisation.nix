{ config, ... }:
{
  virtualisation.waydroid.enable = (
    if config.networking.hostName == "alpha" then
      false
    else
      false

  );
  networking.nftables.enable = false;



}
