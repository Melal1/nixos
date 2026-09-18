{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.virtualisation;
in
{
  options.my.virtualisation = {
    mssql.enable = lib.mkEnableOption "Microsoft SQL Server container (podman backend)";
    docker.enable = lib.mkEnableOption "Docker daemon";
    docker.autoStart = lib.mkEnableOption "Start Docker on boot";
  };

  config = lib.mkMerge [
    {
      virtualisation.waydroid.enable = false;
    }

    (lib.mkIf cfg.mssql.enable {
      virtualisation.podman.enable = true;
      # Microsoft's official SQL Server CLI client
      environment.systemPackages = [ pkgs.sqlcmd ];
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
      # Don't even wake up via socket activation unless autoStart is on
      systemd.sockets.docker.wantedBy = lib.mkIf (!cfg.docker.autoStart) (lib.mkForce [ ]);
      environment.systemPackages = [ pkgs.docker-compose ];
    })
  ];
}
