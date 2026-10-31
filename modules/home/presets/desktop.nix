{ lib, ... }:
{
  home.sessionVariables.BROWSER = lib.mkDefault "helium";
  programs.kitty.enable = lib.mkDefault true;
  programs.foot.enable = lib.mkDefault true;
  my.home = {
    desktop.enable = lib.mkDefault true;
    media.enable = lib.mkDefault true;
    wm.niri.enable = lib.mkDefault true;
    skwd.enable = lib.mkDefault true;
  };
}
