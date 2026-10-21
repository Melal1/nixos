{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.host;
in
{
  options.my.host = {
    arch = lib.mkOption {
      type = lib.types.strMatching "[A-Za-z0-9_+-]+";
      default = pkgs.stdenv.hostPlatform.gcc.arch or "x86-64";
      example = "znver3";
      description = "Default CPU architecture for packages selected with pkgs.optimizeForArch.";
    };

    displays = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Wayland display output names available on this host.";
    };

    hasBattery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host has a battery.";
    };
  };

  config = {
    nixpkgs.overlays = lib.mkAfter [ (import ../../overlays/host-arch.nix cfg.arch) ];

    assertions = [
      {
        assertion = !config.my.hardware.batteryOpt.enable || cfg.hasBattery;
        message = "my.hardware.batteryOpt.enable requires my.host.hasBattery = true.";
      }
    ];
  };
}
