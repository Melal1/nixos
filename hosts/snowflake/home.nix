{ ... }: {
  imports = [ ../../modules/home ];

  my.home = {
    desktop.enable = true;
    media.enable = true;
  };

  # Home Manager owns these per-user applications and their configuration.
  programs = {
    git.enable = true;
    fastfetch.enable = true;
    yazi.enable = true;
    lazygit.enable = true;
    nh.enable = true;
    starship.enable = true;
  };

  home.sessionVariables.BROWSER = "librewolf";
}
