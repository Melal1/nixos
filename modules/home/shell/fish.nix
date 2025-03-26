{
  programs = {

    fish = {
      enable = true;
      shellInit = ''
        set fish_greeting # Disable greeting
        set -g FZF_CTRL_T_COMMAND "command find -L \$dir -type f 2> /dev/null | sed '1d; s#^\./##'"
        set FZF_DEFAULT_COMMAND "find . -path '*/.git/*' -prune -o -printf '%P\n'"
        set -g fish_key_bindings fish_vi_key_bindings
        bind \cE edit_command_buffer
        bind \cQ up-or-search
        bind \cA down-or-search
        bind -M insert \cQ up-or-search
        bind -M insert \cA down-or-search
        bind -M insert \cE edit_command_buffer
        bind -M insert \cD nextd-or-forward-word
        bind -M insert \cF accept-autosuggestion
        bind -M insert -m default jk cancel repaint-mode
        set -g fish_sequence_key_delay_ms 60
        zoxide init fish | source

      '';

      preferAbbrs = true;
      shellAbbrs = {
        vnx = "nvim ~/.dotfiles/nixos/";
        vhm = "nvim ~/.dotfiles/nixos/modules/home/";
        x-r = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
        h-r = "home-manager switch --flake ~/.dotfiles/nixos/.";
        v = "nvim";
        # vim = "nvim";


      };
      shellAliases = {

        nvi = "nvim $(fzf --preview 'bat --color=always {}')";

      };

    };
    fzf.enableFishIntegration = true;
  };
  home.sessionVariables = {
    BROWSER = "zen";
    EDITOR = "nvim";
  };

}
