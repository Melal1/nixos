{

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    flavors = {
      onedark = ./flavors/onedark.yazi;
      rose-pine = ./flavors/rose-pine.yazi;
    };
    theme = {
      flavor =
      {
        dark = "onedark";
      };
    };

  };

}
