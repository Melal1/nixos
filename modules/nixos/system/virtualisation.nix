{
  config,
  lib,
  ...
}:
let
  cfg = config.my.virtualisation;
in
{
  options.my.virtualisation = {
    podman.enable = lib.mkEnableOption "Podman container engine";
    mssql.enable = lib.mkEnableOption "Microsoft SQL Server container (podman backend)";
    docker.enable = lib.mkEnableOption "Docker daemon";
    docker.autoStart = lib.mkEnableOption "Start Docker on boot";
  };

  config = lib.mkMerge [
    {
      virtualisation.waydroid.enable = false;
    }

    (lib.mkIf cfg.podman.enable {
      virtualisation.podman.enable = true;
    })

    (lib.mkIf cfg.mssql.enable {
      assertions = [
        {
          assertion = cfg.podman.enable && config.virtualisation.podman.enable;
          message = "MSSQL requires Podman; enable my.virtualisation.podman.enable.";
        }
      ];
      virtualisation.oci-containers = {
        backend = "podman";
        containers.mssql = {
          image = "mcr.microsoft.com/mssql/server:2022-latest";
          environmentFiles = [ "/var/lib/secrets/mssql.env" ];
          ports = [ "127.0.0.1:1433:1433" ]; # localhost only, no firewall exposure
          # Persist databases across container restarts (service deletes the container on stop)
          volumes = [ "mssql-data:/var/opt/mssql" ];
          autoStart = false; # Keeps your RAM free until you need it
        };
      };
    })

    (lib.mkIf cfg.docker.enable {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = cfg.docker.autoStart;
      };

      systemd.sockets.docker.wantedBy = lib.mkIf (!cfg.docker.autoStart) (lib.mkForce [ ]);
    })
  ];
}
