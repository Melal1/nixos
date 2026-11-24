{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionVariables.EDITOR = lib.mkDefault (
    if config.programs.neovim.enable then "nvim" else "nano"
  );
  home.packages = lib.optional (!config.programs.neovim.enable) pkgs.nano;

  programs = {
    home-manager.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    git = {
      enable = lib.mkDefault true;
      settings.user = {
        name = lib.mkDefault "melal";
        email = lib.mkDefault "melal.1@hotmail.com";
      };
    };
    fastfetch.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    lazygit.enable = lib.mkDefault true;
    nh.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = lib.mkDefault true;
    };
  };

  my.home.scripts = {
    enable = lib.mkDefault true;
    githubUsername = lib.mkDefault "melal1";
    vicinae.enable = lib.mkDefault false;
    assets = {
      url = lib.mkDefault "git@github.com:Melal1/assets.git";
      httpsUrl = lib.mkDefault "https://github.com/Melal1/assets.git";
      quickshellUrl = lib.mkDefault "git@github.com:Melal1/quickshell.git";
      neovimUrl = lib.mkDefault "git@github.com:Melal1/neovim.git";
      neovimBranch = lib.mkDefault "unstable";
    };
  };
}
