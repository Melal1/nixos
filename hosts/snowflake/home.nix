{ ... }: {
  imports = [ ../../modules/home ];
  
  my.home = {
    waybar.theme = "snowflake-v";
    videoWallpaper.enable = true;
  };
}