{
  config,
  lib,
  unstable,
  osConfig ? null,
  ...
}:
let
  cfg = config.my.home.gpu-screen-recorder;
in
{
  options.my.home.gpu-screen-recorder = {
    enable = lib.mkEnableOption "GPU Screen Recorder frontends";
    autostart = lib.mkEnableOption "the GPU Screen Recorder UI overlay at Niri login";
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig == null || (osConfig.programs.gpu-screen-recorder.enable or false);
        message = "GPU Screen Recorder frontends require the NixOS KMS capability wrapper.";
      }
    ];
    home.packages = with unstable; [
      gpu-screen-recorder-gtk
      gpu-screen-recorder-ui
      gpu-screen-recorder-notification
    ];
  };
}
