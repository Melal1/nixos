{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.nix-serve;
in
{
  options.my.services.nix-serve = {
    enable = lib.mkEnableOption "a manually started LAN binary cache";
    interface = lib.mkOption {
      type = lib.types.str;
      example = "enp4s0";
      description = "Ethernet interface on which to open the cache firewall port.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Binary cache HTTP port.";
    };
    keyName = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}-1";
      description = "Name embedded in the generated cache signing key.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      package = pkgs.nix-serve-ng;
      inherit (cfg) port;
      secretKeyFile = "/var/lib/nix-cache/cache.sec";
    };
    # Start with: sudo systemctl start nix-serve
    systemd.services.nix-serve.wantedBy = lib.mkForce [ ];
    networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [ cfg.port ];

    # Generate once at activation; the private key never enters Git or the store.
    system.activationScripts.nixCacheSigningKey = {
      deps = [ "var" ];
      text = ''
        ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/nix-cache
        (
          set -e
          umask 077
          if [ ! -e /var/lib/nix-cache/cache.sec ]; then
            ${config.nix.package}/bin/nix-store --generate-binary-cache-key ${lib.escapeShellArg cfg.keyName} \
              /var/lib/nix-cache/cache.sec /var/lib/nix-cache/cache.pub
          fi
          ${config.nix.package}/bin/nix --extra-experimental-features nix-command \
            key convert-secret-to-public < /var/lib/nix-cache/cache.sec \
            > /var/lib/nix-cache/cache.pub
          ${pkgs.coreutils}/bin/chmod 0600 /var/lib/nix-cache/cache.sec
        )
      '';
    };
  };
}
