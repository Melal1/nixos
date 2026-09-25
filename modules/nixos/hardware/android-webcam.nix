{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.androidWebcam;
in
{
  options.my.hardware.androidWebcam = {
    enable = lib.mkEnableOption "Android webcam support through scrcpy and v4l2loopback";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Load the v4l2loopback kernel module during boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      scrcpy
      v4l-utils
      android-tools
    ];

    # Keep the module available for manual loading even when autoStart is false.
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.kernelModules = lib.optionals cfg.autoStart [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Android WebCam" exclusive_caps=1
    '';
  };
}
