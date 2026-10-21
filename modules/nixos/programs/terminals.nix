{
  lib,
  ...
}:
{
  # These are host defaults consumed by Home Manager. It owns installation and
  # user configuration, including Foot's user service.
  options.my.programs.terminals = {
    kitty.enable = lib.mkEnableOption "Kitty terminal emulator";
    ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";
    foot.enable = lib.mkEnableOption "Foot terminal emulator";
  };
}
