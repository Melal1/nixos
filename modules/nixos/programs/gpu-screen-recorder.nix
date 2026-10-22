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
    enable = lib.mkEnableOption "GPU Screen Recorder and its privileged KMS wrapper";
  };

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder = {
      enable = true;
      package = unstable.gpu-screen-recorder;
    };
  };
}
