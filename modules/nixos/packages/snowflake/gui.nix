{ pkgs, unstable, ... }:
{
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
}
