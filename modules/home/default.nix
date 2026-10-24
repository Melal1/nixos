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
    home = {
      username = "melal";
      homeDirectory = "/home/melal";
      stateVersion = "24.11";
      sessionVariables = {
        BROWSER = lib.mkDefault "helium";
        EDITOR = lib.mkDefault "nvim";
      };
    };

    programs = {
      home-manager.enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      foot.enable = lib.mkDefault true;
      git = {
        enable = lib.mkDefault true;
        settings.user = {
          name = lib.mkDefault "melal";
          email = lib.mkDefault "melal.1@hotmail.com";
        };
      };
      fastfetch.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault true;
      lazygit.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
      direnv = {
        enable = lib.mkDefault true;
        nix-direnv.enable = lib.mkDefault true;
      };
    };

    my.home = {
      desktop.enable = lib.mkDefault true;
      media.enable = lib.mkDefault true;
      wm.niri.enable = lib.mkDefault true;
      skwd.enable = lib.mkDefault true;
      keyboardTools.enable = lib.mkDefault true;
      bluetoothClient.enable = lib.mkDefault true;
      scripts = {
        enable = lib.mkDefault true;
        githubUsername = lib.mkDefault "melal1";
        vicinae.enable = lib.mkDefault false;
        assets = {
          url = lib.mkDefault "git@github.com:Melal1/assets.git";
          httpsUrl = lib.mkDefault "https://github.com/Melal1/assets.git";
          quickshellUrl = lib.mkDefault "git@github.com:Melal1/quickshell.git";
          neovimUrl = lib.mkDefault "git@github.com:Melal1/neovim.git";
          neovimBranch = lib.mkDefault "unstable";
        };
      };
    };

    nixpkgs.config.allowUnfree = lib.mkDefault true;

    # Standalone Home Manager uses its own package set; carry over the same
    # architecture default from its NixOS host instead of configuring it twice.
    nixpkgs.overlays = lib.mkAfter (
      lib.optional (osConfig != null && osConfig ? my.packages.optimization.arch) (
        import ../../overlays/host-arch.nix osConfig.my.packages.optimization.arch
      )
    );
  };
}
