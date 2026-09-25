{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ./kernel.nix
    inputs.pi.nixosModules.default
  ];

  networking.hostName = "rusty";

  my.host = {
    displays = [ "eDP-1" ];
    hasBattery = true;
    gpus = [
      "intel"
      "nvidia"
    ];
  };

  my.virtualisation.mssql.enable = true;

  my.hardware = {
    bluetooth.enable = true;
    gpu.nvidia.enable = true;
    gpu.intel.enable = true;
    touchpad.enable = true;
    batteryOpt.enable = true;
    vial-qmk.enable = true;
  };

  my.desktop = {
    niri.enable = true;
  };

  my.programs = {
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
    [
      inputs.antigravity-nix.packages.${sys}.google-antigravity-cli
      inputs.zen-browser.packages.${sys}.default
      inputs.ditto.packages.${sys}.default
    ];
  programs.pi.coding-agent = {
    enable = true;
  };
}
