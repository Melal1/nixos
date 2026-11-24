{
  config,
  lib,
  ...
}:
let
  cfg = config.my.virtualisation.winapps;
in
{
  options.my.virtualisation.winapps.enable =
    lib.mkEnableOption "WinApps host support and its Home Manager integration";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.virtualisation.podman.enable && config.virtualisation.podman.enable;
        message = "WinApps requires Podman; enable my.virtualisation.podman.enable.";
      }
      {
        assertion = config.virtualisation.containers.containersConf.settings.engine.runtime == "crun";
        message = "WinApps rootless Podman requires crun for group_add: keep-groups.";
      }
    ];

    boot.kernelModules = [
      "tun"
      "ip_tables"
      "iptable_nat"
    ];
    virtualisation.containers.containersConf.settings.engine.runtime = lib.mkDefault "crun";
  };
}
