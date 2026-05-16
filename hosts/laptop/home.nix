{ ... }: {
  imports = [ ../../modules/home ];
  
  my.home = {
    waybar.theme = "zeta";
    scripts.disableHyprlandEffects = true;
  };
}