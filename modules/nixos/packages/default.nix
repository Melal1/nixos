{ lib, ... }: {
  options.my.groups = {
    core.enable = lib.mkEnableOption "Core CLI & system packages" // { default = true; };
    desktop.enable = lib.mkEnableOption "Basic Desktop/GUI packages";
    dev.enable = lib.mkEnableOption "Development tools and languages";
    gaming.enable = lib.mkEnableOption "Gaming packages (Steam, etc.)";
    media.enable = lib.mkEnableOption "Media, audio, and video packages";
    network.enable = lib.mkEnableOption "Networking tools";
    social.enable = lib.mkEnableOption "Social and communication apps";
    laptop.enable = lib.mkEnableOption "Laptop specific utilities";
  };

  imports = [
    ./cache.nix
    ./fonts.nix
    ./groups/core.nix
    ./groups/desktop.nix
    ./groups/dev.nix
    ./groups/gaming.nix
    ./groups/media.nix
    ./groups/network.nix
    ./groups/social.nix
    ./groups/laptop.nix
    ./dev/lsp.nix
    ./dev/languages.nix
    ./dev/libs.nix
  ];
}
