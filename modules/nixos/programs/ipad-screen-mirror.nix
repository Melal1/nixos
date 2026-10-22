{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.my.programs.ipad-screen-mirror;
  ports = lib.range cfg.port (cfg.port + 2);
in
{
  options.my.programs.ipad-screen-mirror = {
    enable = lib.mkEnableOption "manually launched UXPlay with system Avahi and firewall support";
    package = lib.mkPackageOption unstable "uxplay" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7000;
      description = "First of three consecutive UXPlay TCP/UDP receiver ports.";
    };
    receiverName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional advertised name. Coordinate names and ports before running multiple receivers.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.port <= 65533;
        message = "UXPlay needs three consecutive ports.";
      }
    ];

    # The user launches the receiver manually after an administrator starts Avahi.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "uxplay";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          if ! systemctl --system is-active --quiet avahi-daemon.service; then
            echo 'UXPlay requires the system Avahi daemon to be running. Ask an administrator to start avahi-daemon.service before mirroring.' >&2
            exit 1
          fi
          exec ${lib.getExe cfg.package} -p ${toString cfg.port} ${
            lib.optionalString (cfg.receiverName != null) "-n ${lib.escapeShellArg cfg.receiverName}"
          } "$@"
        '';
      })
    ];

    services.avahi = {
      enable = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # Start discovery manually when mirroring: sudo systemctl start avahi-daemon.service
    # Clear the socket target too, so socket traffic cannot start it at boot.
    systemd.services.avahi-daemon.wantedBy = lib.mkForce [ ];
    systemd.sockets.avahi-daemon.wantedBy = lib.mkForce [ ];

    networking.firewall.allowedTCPPorts = ports;
    networking.firewall.allowedUDPPorts = ports;
  };
}
