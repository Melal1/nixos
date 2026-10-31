{
  config,
  lib,
  osConfig ? null,
  ...
}:
{
  options.my.home.dotfilesDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles/nixos";
    description = "Absolute path to this repo checkout, used for out-of-store symlinks.";
  };

  imports = [
    ./core.nix
    ./programs
    ./shell
    ./dev
    ./scripts
    ./gtk.nix
  ];

  config = {
    home = {
      username = "melal";
      homeDirectory = "/home/melal";
      stateVersion = "24.11";
    };

    nixpkgs.config.allowUnfree = lib.mkDefault true;

    nixpkgs.overlays = lib.mkAfter (
      lib.optional (osConfig != null && osConfig ? my.packages.optimization.arch) (
        import ../../overlays/host-arch.nix osConfig.my.packages.optimization.arch
      )
    );
  };
}
