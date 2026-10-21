{
  config,
  inputs,
  lib,
  pkgs,
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

  my.packages = {
    cli = {
      shared.enable = true;
      host.enable = true;
    };
    gui = {
      shared.enable = true;
      host.enable = true;
    };
    io = {
      shared.enable = true;
      host.enable = true;
    };
    development = {
      shared.enable = true;
      host.enable = true;
    };
    fonts = {
      shared.enable = true;
      host.enable = true;
    };
  };

  my.development.toolchains = {
    audio.enable = true;
    avalonia.enable = true;
    cpp.enable = true;
    dotnet.enable = true;
    dpp.enable = true;
    fmt.enable = true;
    go.enable = true;
    lua.enable = true;
    ncurses.enable = true;
    nodejs22.enable = true;
    py.enable = true;
    py-science.enable = true;
    qksh.enable = true;
    rust.enable = true;
  };

  my.programs = {
    nix-ld.enable = true;
    gpu-screen-recorder.enable = true;
    easyeffects.enable = true;
    steam.enable = true;
    ipad-screen-mirror.enable = true;
    obs.enable = true;
    terminals = {
      kitty.enable = true;
      foot.enable = true;
      ghostty.enable = false;
    };
  };

  # Host-specific packages coming from flake inputs
  environment.systemPackages =
    let
      sys = pkgs.stdenv.hostPlatform.system;
    in
    lib.optional config.my.packages.gui.host.enable inputs.helium-flake.packages.${sys}.default
    ++ lib.optionals config.my.packages.cli.host.enable [
      inputs.tincan-cli.packages.${sys}.default
      inputs.timr-tui.packages.${sys}.linuxSound
    ];
}
