{ config, lib, pkgs, ... }:
{
  options.my.hardware.gpu.intel.enable = lib.mkEnableOption "Intel GPU support";

  config = lib.mkIf config.my.hardware.gpu.intel.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
