{ ... }: {
  imports = [ ../../modules/home ];

  my.home = {
    waybar.theme = "rusty";
    scripts.disableHyprlandEffects = true;
  };
}
