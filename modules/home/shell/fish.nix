{
  pkgs,
  lib,
  config,
  hostname,
  unstable,
  ...
}:
{
  config = lib.mkIf config.programs.fish.enable {
    home.packages = with pkgs; [
      grc
      fzf
      tmux
      ripgrep
      bat
      lsd
      unstable.neovim
    ];
    programs = {
      fish = {
        plugins = [
          # Enable a plugin (here grc for colorized command output) from nixpkgs
          {
            name = "grc";
            src = pkgs.fishPlugins.grc.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];

        shellInit = builtins.readFile ./init.fish;

        preferAbbrs = lib.mkDefault true;
        shellAbbrs = {
          vnx = lib.mkDefault "nvim ~/.dotfiles/nixos/";
          xpkg = lib.mkDefault "nvim ~/.dotfiles/nixos/modules/home/packages/";
          vhm = lib.mkDefault "nvim ~/.dotfiles/nixos/modules/home/";
          qa = lib.mkDefault "exit";
          x-r = lib.mkDefault "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
          h-r = lib.mkDefault "home-manager switch --flake ${config.my.home.dotfilesDir}/#${config.home.username}@${hostname}";
        };

        shellAliases = {
          nvi = lib.mkDefault "nvim $(fzf --preview 'bat --color=always {}')";
          v = lib.mkDefault "nvim";
          vim = lib.mkDefault "nvim";
          vi = lib.mkDefault "nvim";
        };
      };
    };

  };
}
