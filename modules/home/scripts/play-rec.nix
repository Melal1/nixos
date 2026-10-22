{
  config,
  lib,
  pkgs,
  ...
}:

let
  gsrEnabled = config.my.home.gpu-screen-recorder.enable;

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

  hasMpv = config.programs.mpv.enable || containsMpv config.home.packages;
in
{
  home.file.".local/bin/mpv-mix" = lib.mkIf (gsrEnabled && hasMpv) {
    executable = true;

    text = ''
      #!${pkgs.bash}/bin/bash
      exec ${lib.getExe pkgs.mpv} --lavfi-complex="[aid1][aid2]amix=inputs=2[ao]" "$1"
    '';
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
}
