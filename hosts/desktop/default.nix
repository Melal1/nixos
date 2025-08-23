{
  imports = [
    ./hardware/configuration.nix
    ./users/melal.nix
    ./structure.nix
    ./kernel.nix
  ];
  networking.hostName = "alpha";
}
