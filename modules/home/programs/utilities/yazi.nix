{

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    flavors = {
      onedark = ./config/yazi/flavors/onedark.yazi;
      rose-pine = ./config/yazi/flavors/rose-pine.yazi;
    };
    theme = {
      flavor =
      {
        dark = "onedark";
      };
    };

  };

}
