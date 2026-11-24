{
  config,
  inputs,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  enabled = osConfig != null && (osConfig.my.virtualisation.winapps.enable or false);
  cfg = config.my.home.winapps;
  suite = inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system};
  # Upstream WinApps uses this location even when XDG_CONFIG_HOME differs.
  winappsDir = "${config.home.homeDirectory}/.config/winapps";
  compose = {
    name = "winapps";
    volumes.data = { };
    services.windows = {
      image = "ghcr.io/dockur/windows:latest";
      container_name = "WinApps";
      env_file = [ "${winappsDir}/windows.env" ];
      environment = {
        VERSION = cfg.windowsVersion;
        RAM_SIZE = cfg.ramSize;
        CPU_CORES = toString cfg.cpuCores;
        DISK_SIZE = cfg.diskSize;
        HOME = config.home.homeDirectory;
      };
      ports = [
        "127.0.0.1:8006:8006"
        "127.0.0.1:3389:3389/tcp"
        "127.0.0.1:3389:3389/udp"
      ];
      cap_add = [
        "NET_ADMIN"
        "NET_RAW"
      ];
      stop_grace_period = "120s";
      restart = "no";
      volumes = [
        "data:/storage"
        "${config.home.homeDirectory}:/shared"
        "${winappsDir}/oem:/oem:ro"
      ];
      devices = [
        "/dev/kvm"
        "/dev/net/tun"
      ];
      group_add = [ "keep-groups" ];
    };
  };
in
{
  # Enablement belongs to NixOS; these only customize the user integration.
  options.my.home.winapps = {
    launcher.enable = lib.mkEnableOption "the optional WinApps tray launcher";
    windowsVersion = lib.mkOption {
      type = lib.types.str;
      default = "11";
      description = "Windows edition selector supported by dockur/windows.";
    };
    ramSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "RAM allocated to the Windows VM.";
    };
    cpuCores = lib.mkOption {
      type = lib.types.ints.positive;
      default = 4;
      description = "Virtual CPUs allocated to the Windows VM.";
    };
    diskSize = lib.mkOption {
      type = lib.types.str;
      default = "128G";
      description = "Initial capacity of the persistent Windows disk.";
    };
  };

  config = lib.mkIf enabled {
    assertions = [
      {
        assertion =
          (osConfig.my.virtualisation.podman.enable or false)
          && (osConfig.virtualisation.podman.enable or false);
        message = "WinApps requires Podman on its NixOS host.";
      }
    ];
    home.packages = [
      suite.winapps
      pkgs.podman-compose
    ]
    ++ lib.optional cfg.launcher.enable suite.winapps-launcher;

    home.file = {
      # JSON is valid YAML and preserves Compose values without hand escaping.
      ".config/winapps/compose.yaml".text = builtins.toJSON compose;
      ".config/winapps/oem".source = "${inputs.winapps}/oem";
      ".config/winapps/windows.env.example".text = ''
        # Copy to windows.env with mode 600 before the first VM start.
        # Choose a Windows account and password; use the same values in winapps.conf.
        USERNAME='${config.home.username}'
        PASSWORD='REPLACE_ME'
      '';
      ".config/winapps/winapps.conf.example".text = ''
        # Copy to winapps.conf with mode 600, then fill in your Windows credentials.
        WAFLAVOR="podman"
        RDP_IP="127.0.0.1"
        RDP_USER="${config.home.username}"
        RDP_PASS="REPLACE_ME"
        RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
      '';
    };
  };
}
