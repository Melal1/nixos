{ config, ... }:
{
  virtualisation.waydroid.enable = (
    if config.networking.hostName == "alpha" then
      true
    else
      false

  );
  networking.nftables.enable = false;



}
