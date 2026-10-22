{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./keyboard.nix
    ./kernel.nix
    ../../modules/nixos
  ];

  networking.hostName = "snowflake";

  my.services.nix-serve = {
    enable = true;
    interface = "enp4s0";
  };

  boot.loader.grub.useOSProber = true;

  my.host = {
    arch = "znver3";
    displays = [
      "DP-1"
      "HDMI-A-1"
    ];
    hasBattery = false;
  };

  my.virtualisation.mssql.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    gpu.amd.enable = true;
    performance.enable = true;
    vial-qmk.enable = true;
    rgb.enable = true;
    disablePcieWakeup.enable = true;
    androidWebcam = {
      enable = true;
      autoStart = false;

    };
  };

  my.desktop = {
    niri.enable = true;
  };

  my.packages.fonts.shared.enable = true;

  my.programs = {
    nix-ld.enable = true;
    gpu-screen-recorder.enable = true;
    steam.enable = true;
    ipad-screen-mirror.enable = true;

  };

  # Shared audio/session and shell backends are independent host capabilities.
  programs.dconf.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = lib.mkIf (!config.services.tuned.enable) true;
}
