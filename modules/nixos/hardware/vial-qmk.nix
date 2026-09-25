{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.hardware.vial-qmk.enable = lib.mkEnableOption "Enable vial-qmk Keyboards";

  config = lib.mkIf config.my.hardware.vial-qmk.enable {
    hardware.keyboard.qmk.enable = true;
    environment.systemPackages = with pkgs; [
      vial
      qmk
      via
    ];
    services.udev.packages = [ pkgs.via ];
  };
}
