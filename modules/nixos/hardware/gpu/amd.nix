{
  config,
  lib,
  ...
}:
{
  options.my.hardware.gpu.amd.enable = lib.mkEnableOption "AMD GPU support";

  config = lib.mkIf config.my.hardware.gpu.amd.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # LACT provides AMD GPU monitoring and optional clock/fan control.
    # Its daemon is required for the UI to apply hardware settings.
    services.lact.enable = true;
    hardware.amdgpu.overdrive.enable = true;
  };
}
