{ config, lib, ... }:
{
  options.my.hardware.gpu.nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";

  config = lib.mkIf config.my.hardware.gpu.nvidia.enable {
    # Enable OpenGL
    hardware.graphics.enable = true;

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Nvidia power management. Experimental, can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental, Turing or newer only.
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not nouveau).
      # Turing and later only, driver 515.43.04+.
      open = false;

      # Enable the `nvidia-settings` menu.
      nvidiaSettings = true;

      # stable always fails to build
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}
