{
  imports = [
    ./kitty.nix
    ./ghostty.nix
  ];

  home.file.".config/kitty/themes" = {
  source = ./themes;
  recursive = true;   # copy everything inside
  force = true;       # overwrite if exists
};



}
