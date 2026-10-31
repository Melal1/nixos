{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home/presets/desktop.nix
    ../../modules/home/presets/development.nix
    ../../modules/home/packages/cli.nix
    ../../modules/home/packages/desktop-apps.nix
    ../../modules/home/packages/io.nix
    ../../modules/home/packages/database-clients.nix
    ./home-packages.nix
  ];

  # buildEnv keeps the priority of the first occurrence of an output.
  home.packages = lib.mkIf config.my.home.noctalia.enable (lib.mkBefore [ pkgs.python3 ]);

  my.home = {
    noctalia.enable = lib.mkDefault true;
    keyboardTools.enable = lib.mkDefault true;
    bluetoothClient.enable = lib.mkDefault true;
    dev = {
      csharp.avalonia.enable = lib.mkDefault true;
      python.science.enable = lib.mkDefault true;
      javascript.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      rust.enable = lib.mkDefault true;
    };
    openrgb.enable = lib.mkDefault true;
    gpu-screen-recorder = {
      enable = lib.mkDefault true;
      autostart = lib.mkDefault true;
    };
    obs.gstreamer.enable = lib.mkDefault true;
  };
  services.easyeffects.enable = lib.mkDefault true;
  programs.obs-studio.enable = lib.mkDefault true;
}
