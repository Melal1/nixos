{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home;
in
{
  options.my.home = {
    keyboardTools.enable = lib.mkEnableOption "QMK, Vial and VIA clients";
    bluetoothClient.enable = lib.mkEnableOption "the Bluetooth TUI";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.keyboardTools.enable {
      home.packages = with pkgs; [
        vial
        qmk
        via
      ];
    })
    (lib.mkIf cfg.bluetoothClient.enable { home.packages = [ pkgs.bluetui ]; })
  ];
}
