{
  unstable,
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.ipad-screen-mirror;
in
{
  options.my.programs.ipad-screen-mirror = {
    enable = lib.mkEnableOption "Enables iPad mirroring via UxPlay and Avahi";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      unstable.uxplay
    ];

    services.avahi = {
      enable = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    networking.firewall.allowedTCPPorts = [
      7000
      7001
      7002
    ];

    networking.firewall.allowedUDPPorts = [
      7000
      7001
      7002
    ];
  };
}
