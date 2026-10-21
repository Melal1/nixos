{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.noctalia;
in
{
  imports = [ inputs.noctalia.nixosModules.default ];

  options.my.programs.noctalia = {
    enable = lib.mkEnableOption "Noctalia shell and its recommended services";
    optimize_for_arch = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Build Noctalia from source for my.host.arch using the shared pkgs.optimizeForArch helper.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      package = pkgs.optimizeForArch {
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        inherit (cfg) optimize_for_arch;
      };
      recommendedServices.enable = true;
    };
  };
}
