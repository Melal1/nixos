{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.gui.host.enable {
    environment.systemPackages =
      (with pkgs; [
        prismlauncher
        logisim-evolution
        element-desktop
        puddletag
        libreoffice
      ])
      ++ (with unstable; [
        vlc
        anydesk
        opencode-desktop
      ]);
  };
}
