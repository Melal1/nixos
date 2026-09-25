{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.my.programs.terminals;
in
{
  options.my.programs.terminals = {
    kitty.enable = lib.mkEnableOption "Kitty terminal emulator";
    ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";
    foot.enable = lib.mkEnableOption "Foot terminal emulator";
  };

  config = {
    environment.systemPackages =
      lib.optional cfg.kitty.enable unstable.kitty
      ++ lib.optional cfg.ghostty.enable unstable.ghostty
      ++ lib.optional cfg.foot.enable unstable.foot;
  };
}
