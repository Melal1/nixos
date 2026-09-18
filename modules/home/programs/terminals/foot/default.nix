{
  config,
  lib,
  unstable,
  ...
}:
lib.mkIf config.my.home.terminals.foot.enable {
  programs.foot = {
    enable = true;
    package = unstable.foot;

    server.enable = true;

    settings = {
      main = {
        font = "CaskaydiaCove Nerd Font:style=SemiBold:size=14";
      };

      "colors-dark" = {
        foreground = "cdcdcd";
        background = "141415";
        selection-foreground = "cdcdcd";
        selection-background = "878787";
        alpha = 0.7;

        regular0 = "252530";
        regular1 = "d8647e";
        regular2 = "7fa563";
        regular3 = "f3be7c";
        regular4 = "6e94b2";
        regular5 = "bb9dbd";
        regular6 = "aeaed1";
        regular7 = "cdcdcd";

        bright0 = "606079";
        bright1 = "e08398";
        bright2 = "99b782";
        bright3 = "f5cb96";
        bright4 = "8ba9c1";
        bright5 = "c9b1ca";
        bright6 = "bebeda";
        bright7 = "d7d7d7";
      };

      cursor = {
        style = "block";
      };

      key-bindings = {
        clipboard-copy = "Control+Shift+c";
        clipboard-paste = "Control+Shift+v";
        font-increase = "Control+equal Control+plus Control+Shift+equal Control+Shift+plus";
        font-decrease = "Control+minus";
        font-reset = "Control+0";
      };
    };
  };
}
