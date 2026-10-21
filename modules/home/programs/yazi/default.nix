{ config, ... }:
{
  programs.yazi = {
    enableFishIntegration = config.programs.fish.enable;
    shellWrapperName = "y";
    flavors = {
      onedark = ./flavors/onedark.yazi;
      rose-pine = ./flavors/rose-pine.yazi;
    };
    theme = {
      flavor = {
        dark = "onedark";
      };
    };

  };

}
