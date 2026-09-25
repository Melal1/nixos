{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./keyboard.nix
    ./kernel.nix
    ../../modules/nixos
  ];

  networking.hostName = "snowflake";

  my.host = {
    displays = [
      "DP-1"
      "HDMI-A-1"
    ];
    hasBattery = false;
    gpus = [ "amd" ];
  };

  my.virtualisation.mssql.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    gpu.amd.enable = true;
    performance.enable = true;
    vial-qmk.enable = true;
    rgb.enable = true;
    androidWebcam = {
      enable = true;
      autoStart = false;

    };
  };

  my.desktop = {
    niri.enable = true;
  };

  my.programs = {
    gpu-screen-recorder.enable = true;
    easyeffects.enable = true;
    steam.enable = true;
    obs.enable = true;
    terminals = {
      kitty.enable = true;
      foot.enable = true;
      ghostty.enable = false;
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  # Host-specific packages coming from flake inputs
  environment.systemPackages =
    let
      sys = pkgs.stdenv.hostPlatform.system;
    in
    [
      inputs.ditto.packages.${sys}.default
      inputs.zen-browser.packages.${sys}.default
      inputs.antigravity-nix.packages.${sys}.google-antigravity-cli
    ];
}
