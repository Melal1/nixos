# AMD only
{ config, lib, ... }:
{
  options.my.hardware.performance.enable = lib.mkEnableOption "AMD performance tuning";

  config = lib.mkIf config.my.hardware.performance.enable {
    powerManagement.cpuFreqGovernor = "performance";
    hardware.cpu.amd.updateMicrocode = true;
    boot.kernelParams = [ "amd_pstate=active" ];
  };
}
