{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users
    ../../modules/nixos
    ../../profiles/workstation.nix
    inputs.pi.nixosModules.default
  ];

  networking.hostName = "zeta";

  my.hardware = {
    gpu.nvidia.enable = true;
    gpu.intel.enable = true;
    touchpad.enable = true;
    batteryOpt.enable = true;
  };

  # Host-specific packages coming from flake inputs
  environment.systemPackages =
    let sys = pkgs.stdenv.hostPlatform.system; in
    [
      inputs.antigravity-nix.packages.${sys}.google-antigravity-cli
      inputs.zen-browser.packages.${sys}.default
    ];
  programs.pi.coding-agent = {
    enable = true;
  };
}
