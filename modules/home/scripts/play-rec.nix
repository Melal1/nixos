{
  config,
  lib,
  osConfig ? null,
  ...
}:

let
  gsrEnabled =
    if osConfig != null && (osConfig ? my.programs.gpu-screen-recorder.enable) then
      osConfig.my.programs.gpu-screen-recorder.enable
    else
      false;

  containsMpv =
    packages:
    # Nixpkgs' wrapped mpv package is named mpv-with-scripts.
    lib.any (
      pkg:
      builtins.elem (lib.getName pkg) [
        "mpv"
        "mpv-with-scripts"
      ]
    ) packages;

  hasMpv =
    config.programs.mpv.enable
    || containsMpv config.home.packages
    || (osConfig != null && containsMpv osConfig.environment.systemPackages);
in
{
  home.file.".local/bin/mpv-mix" = lib.mkIf (gsrEnabled && hasMpv) {
    executable = true;

    text = ''
      #!/usr/bin/env bash
      mpv --lavfi-complex="[aid1][aid2]amix=inputs=2[ao]" "$1"
    '';
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
}
