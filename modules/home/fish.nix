{
  programs = {

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set -g FZF_CTRL_T_COMMAND "command find -L \$dir -type f 2> /dev/null | sed '1d; s#^\./##'"
        set FZF_DEFAULT_COMMAND "find . -path '*/.git/*' -prune -o -printf '%P\n'"
        set -g fish_key_bindings fish_vi_key_bindings
        bind \cE edit_command_buffer
        bind -M insert -m default jk cancel repaint-mode
        set -g fish_sequence_key_delay_ms 30
      '';
      preferAbbrs = true;
      shellAbbrs = {
        vnx = "nvim ~/.dotfiles/nixos/";
        x-r = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
        h-r = "home-manager switch --flake ~/.dotfiles/nixos/.";

      };
      shellAliases = {

        nvi = "nvim $(fzf --preview 'bat --color=always {}')";
        z = "zoxide";
        zi = "zoxide $(fzf)";

      };

    };
    fzf.enableFishIntegration = true;
    zoxide.enableFishIntegration = true;
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };

}
