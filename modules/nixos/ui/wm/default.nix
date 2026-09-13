{ windowManager, ... }:

{
  imports = [ ./config.nix ];
  my.desktop.type = windowManager;
}
