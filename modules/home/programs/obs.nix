{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
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
  options.my.home.obs.gstreamer.enable =
    lib.mkEnableOption "the OBS GStreamer input with UDP/RTP and software decoders";

  config = lib.mkIf config.programs.obs-studio.enable {
    programs.obs-studio = {
      plugins =
        with pkgs.obs-studio-plugins;
        [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vkcapture
        ]
        # VA-API hardware acceleration for AMD GPUs
        ++ lib.optionals (osConfig != null && (osConfig.my.hardware.gpu.amd.enable or false)) [
          obs-vaapi
        ]
        ++ lib.optionals config.my.home.obs.gstreamer.enable [
          obsGstreamer
        ];
    };
  };
}
