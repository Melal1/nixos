{ pkgs, unstable, ... }:
{
  environment.systemPackages =
    (with pkgs; [
      btop-rocm
      imagemagick
      ninja
    ])
    ++ [
      unstable.codex
    ];
}
