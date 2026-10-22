{
  lib,
  ...
}:
{
  options.my.home.wm = {
    niri.enable = lib.mkEnableOption "Niri user configuration (requires a host Niri session)";
  };

  imports = [
    ./niri
  ];
}
