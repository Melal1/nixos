{
  config,
  lib,
  unstable,
  ...
}:
lib.mkIf config.programs.foot.enable {
  programs.foot = {
    package = lib.mkDefault unstable.foot;

    server.enable = lib.mkDefault true;

    settings = {
      main = {
        font = lib.mkDefault "CaskaydiaCove Nerd Font:style=SemiBold:size=14";
      };

      "colors-dark" = {
        foreground = lib.mkDefault "cdcdcd";
        background = lib.mkDefault "141415";
        selection-foreground = lib.mkDefault "cdcdcd";
        selection-background = lib.mkDefault "878787";
        alpha = lib.mkDefault 0.8;

        regular0 = lib.mkDefault "252530";
        regular1 = lib.mkDefault "d8647e";
        regular2 = lib.mkDefault "7fa563";
        regular3 = lib.mkDefault "f3be7c";
        regular4 = lib.mkDefault "6e94b2";
        regular5 = lib.mkDefault "bb9dbd";
        regular6 = lib.mkDefault "aeaed1";
        regular7 = lib.mkDefault "cdcdcd";

        bright0 = lib.mkDefault "606079";
        bright1 = lib.mkDefault "e08398";
        bright2 = lib.mkDefault "99b782";
        bright3 = lib.mkDefault "f5cb96";
        bright4 = lib.mkDefault "8ba9c1";
        bright5 = lib.mkDefault "c9b1ca";
        bright6 = lib.mkDefault "bebeda";
        bright7 = lib.mkDefault "d7d7d7";
      };

      cursor = {
        style = lib.mkDefault "block";
      };

      key-bindings = {
        clipboard-copy = lib.mkDefault "Control+Shift+c";
        clipboard-paste = lib.mkDefault "Control+Shift+v";
        font-increase = lib.mkDefault "Control+equal Control+plus Control+Shift+equal Control+Shift+plus";
        font-decrease = lib.mkDefault "Control+minus";
        font-reset = lib.mkDefault "Control+0";
      };
    };
  };
}
