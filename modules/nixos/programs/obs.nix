{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.obs;
in
{
  options.my.programs.obs = {
    enable = lib.mkEnableOption "OBS Studio with hardware-appropriate plugins";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins =
        with pkgs.obs-studio-plugins;
        [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vkcapture
        ]
        # VA-API hardware acceleration for AMD GPUs
        ++ lib.optionals config.my.hardware.gpu.amd.enable [
          obs-vaapi
        ];
    };
  };
}
