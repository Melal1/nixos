{ lib, ... }:
{
  imports = [
    ../../modules/home/presets/desktop.nix
    ../../modules/home/presets/development.nix
    ../../modules/home/packages/cli.nix
    ../../modules/home/packages/desktop-apps.nix
    ../../modules/home/packages/io.nix
    ../../modules/home/packages/database-clients.nix
    ./home-packages.nix
  ];

  my.home = {
    noctalia.enable = lib.mkDefault true;
    keyboardTools.enable = lib.mkDefault true;
    bluetoothClient.enable = lib.mkDefault true;
  };
}
