{ config, lib, ... }:
{
  programs.yazi = {
    enableFishIntegration = config.programs.fish.enable;
    shellWrapperName = lib.mkDefault "y";
    flavors = {
      onedark = lib.mkDefault ./flavors/onedark.yazi;
      rose-pine = lib.mkDefault ./flavors/rose-pine.yazi;
    };
    theme = {
      flavor = {
        dark = lib.mkDefault "onedark";
      };
    };

  };

}
