{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.skwd;
  suite = inputs.skwd-wall.packages.${pkgs.stdenv.hostPlatform.system};
  modelHome = "${cfg.modelPackage}/share/skwd-lens/models/semantic";
in
{
  options.my.home.skwd = {
    enable = lib.mkEnableOption "the Skwd wallpaper suite and graphical-session user daemon";
    modelPackage = lib.mkOption {
      type = lib.types.package;
      default = suite.skwd-lens-model;
      description = "Skwd Lens model pack.";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra Skwd backends.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      suite.default
      cfg.modelPackage
    ]
    ++ cfg.extraPackages;
    home.sessionVariables.SKWD_LENS_HOME = modelHome;
    systemd.user.services.skwd-walld = {
      Unit = {
        Description = "skwd-wall control daemon";
        Conflicts = [ "skwd-daemon.service" ];
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${suite.deck}/bin/skwd-walld";
        Restart = "on-failure";
        Environment = [
          "SKWD_LENS_HOME=${modelHome}"
          "PATH=${
            lib.makeBinPath (
              [
                suite.paper
                suite.lens
                pkgs.coreutils
                pkgs.findutils
                pkgs.gnugrep
                pkgs.gnused
                pkgs.systemd
              ]
              ++ cfg.extraPackages
            )
          }"
        ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
