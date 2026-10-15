{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.obs;

  obsGstreamer = pkgs.obs-studio-plugins.obs-gstreamer.overrideAttrs (old: {
    passthru = (old.passthru or { }) // {
      # Include UDP/RTP elements and software decoders in OBS's own launcher.
      obsWrapperArguments =
        (old.passthru.obsWrapperArguments or [ ])
        ++ map (plugin: "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.getLib plugin}/lib/gstreamer-1.0") (
          with pkgs.gst_all_1;
          [
            gst-plugins-good
            gst-libav
          ]
        );
    };
  });
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
        ]
        ++ lib.optionals config.my.programs.ipad-screen-mirror.enable [
          obsGstreamer
        ];
    };
  };
}
