{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.io.host.enable {
    environment.systemPackages = with pkgs; [
      ntfs3g
    ];
  };
}
