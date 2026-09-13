{
  services.picom = {
    enable = true;

    backend = "glx";

    vSync = true;


    settings = {
      inactive-opacity = 1.0;
      blur = {
        method = "dual_kawase";
        strength = 7;
      };
    };
  };

  #      backend = "glx";
  #   vsync = true;
  #
  #   inactive-opacity = 1.0;
  #   frame-opacity = 1.0;
  #   inactive-opacity-override = false;
  #   # inactive-dim = 0.2;
  #   blur:
  # {
  #   method = "dual_kawase";
  #   strength = 8;
  # };
  #
  #
  #   # Needed so per-pixel alpha windows stay composited
  #   unredir-if-possible = false;

}
