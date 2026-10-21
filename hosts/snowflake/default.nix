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

  # Serve the existing store over Ethernet only when manually started.
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    port = 5000;
    secretKeyFile = "/var/lib/nix-cache/cache.sec";
  };
  systemd.services.nix-serve.wantedBy = lib.mkForce [ ];
  networking.firewall.interfaces.enp4s0.allowedTCPPorts = [ 5000 ];

  # Generate once at activation; the private key never enters Git or the store.
  system.activationScripts.nixCacheSigningKey = {
    deps = [ "var" ];
    text = ''
      ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/nix-cache
      (
        set -e
        umask 077
        if [ ! -e /var/lib/nix-cache/cache.sec ]; then
          ${config.nix.package}/bin/nix-store --generate-binary-cache-key snowflake-1 \
            /var/lib/nix-cache/cache.sec /var/lib/nix-cache/cache.pub
        fi
        ${config.nix.package}/bin/nix --extra-experimental-features nix-command \
          key convert-secret-to-public < /var/lib/nix-cache/cache.sec \
          > /var/lib/nix-cache/cache.pub
        ${pkgs.coreutils}/bin/chmod 0600 /var/lib/nix-cache/cache.sec
      )
    '';
  };

  boot.loader.grub.useOSProber = true;

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

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  # Host-specific packages coming from flake inputs
  environment.systemPackages =
    let
      sys = pkgs.stdenv.hostPlatform.system;
    in
    [
      inputs.helium-flake.packages.${sys}.default
      inputs.tincan-cli.packages.${sys}.default
      inputs.timr-tui.packages.${sys}.linuxSound
    ];
}
