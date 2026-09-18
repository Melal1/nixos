{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.easyeffects;
in
{
  options.my.programs.easyeffects = {
    enable = lib.mkEnableOption "EasyEffects audio effects for PipeWire";
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;

    environment.systemPackages = [
      pkgs.easyeffects
    ];
  };
}
