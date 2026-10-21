{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.gui.host.enable {
    environment.systemPackages = with pkgs; [
      nmgui
    ];
  };
}
