{ config, ... }:
{
  virtualisation.waydroid.enable = (
    if config.networking.hostName == "snowflake" then
      false
    else
      false

  );
}
