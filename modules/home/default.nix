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
    ./programs
    ./shell
    ./dev
    ./scripts
    ./gtk.nix
  ];

  config = {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    # Standalone Home Manager uses its own package set; carry over the same
    # architecture default from its NixOS host instead of configuring it twice.
    nixpkgs.overlays = lib.mkAfter (
      lib.optional (osConfig != null && osConfig ? my.host.arch) (
        import ../../overlays/host-arch.nix osConfig.my.host.arch
      )
    );
  };
}
