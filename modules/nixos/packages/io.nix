{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.io.shared.enable {
    environment.systemPackages =
      with pkgs;
      [
        jmtpfs
        alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
        android-tools
      ]
      ++ lib.optional (
        config.my.packages.gui.shared.enable || config.my.packages.gui.host.enable
      ) pavucontrol;
  };
}
