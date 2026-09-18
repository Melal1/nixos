{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.my.programs.gpu-screen-recorder;
in
{
  options.my.programs.gpu-screen-recorder = {
    enable = lib.mkEnableOption "GPU Screen Recorder with GTK and UI frontends";
  };

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder = {
      enable = true;
      package = unstable.gpu-screen-recorder;
    };

    environment.systemPackages = [
      unstable.gpu-screen-recorder-gtk
      unstable.gpu-screen-recorder-ui
      unstable.gpu-screen-recorder-notification
    ];
  };
}
