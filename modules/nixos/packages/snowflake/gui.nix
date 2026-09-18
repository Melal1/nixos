{ pkgs, unstable, ... }:
{
  environment.systemPackages =
    (with pkgs; [
      prismlauncher
      logisim-evolution
      puddletag
    ])
    ++ (with unstable; [
      vlc
      anydesk
      opencode-desktop
    ]);
}
