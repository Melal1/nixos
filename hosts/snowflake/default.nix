{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./keyboard.nix
    ./kernel.nix
    ../../users
    ../../modules/nixos
  ];

  networking.hostName = "snowflake";

  my.hardware = {
    bluetooth.enable = true;
    gpu.amd.enable = true;
    performance.enable = true;
    vial-qmk.enable = true;
    rgb.enable = true;
  };

  my.services.extraGraphics.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  # Host-specific packages coming from flake inputs
  environment.systemPackages =
    let sys = pkgs.stdenv.hostPlatform.system; in
    [
      inputs.ditto.packages.${sys}.default
      inputs.zen-browser.packages.${sys}.default
      inputs.antigravity-nix.packages.${sys}.google-antigravity-cli
      # inputs.music-sep.packages.${sys}.default
    ];
}
