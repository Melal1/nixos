{ lib, ... }:
{
  programs.git = {
    settings = {
      init.defaultbranch = lib.mkDefault "main";
    };
  };
}
