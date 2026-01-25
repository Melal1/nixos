{
  imports = [
    ./kitty.nix
  ];

  home.file.".config/kitty/themes" = {
  source = ./themes;
  recursive = true;   # copy everything inside
  force = true;       # overwrite if exists
  };
  home.file.".config/kitty/kittyAlt.conf" = {
  source = ./kittyALT.conf;
};



}
