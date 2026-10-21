{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.cli.host.enable {
    environment.systemPackages =
      (with pkgs; [
        btop-rocm
        imagemagick
        iamb
      ])
      ++ (with unstable; [
        # (timr-tui.override { enableSound = true; })
        codex
        cloudflared
      ]);
  };
}
