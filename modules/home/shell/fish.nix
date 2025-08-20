{ pkgs, ... }: {
  programs = {
    fish = {
      enable = true;

      shellInit = ''
        function fish_title
            set -q argv[1]; or set argv fish

            if test "$argv[1]" = "fish"
                echo (prompt_pwd --dir-length=0)
            else
                echo "$argv[1]"
            end
        end

        set fish_greeting # Disable greeting
        



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
        bind --erase \cr
        bind --erase \ct
        bind --erase \ef
        bind --erase \ec
        bind --erase -M insert \cr
        bind --erase -M insert \ct
        bind --erase -M insert \ec
        bind \cx fzf-history-widget
        bind \cs nvi
        bind \ec fzf-cd-widget
        bind -M insert \cx fzf-history-widget
        bind -M insert \cs nvi
        bind -M insert \ec fzf-cd-widget

        set -x FZF_ALT_C_OPTS "--preview 'test -d {} && lsd --tree --depth=1 --icon=always --color=always {} || echo {} is not a directory'"

        set -x FZF_DEFAULT_OPTS '--height 70% --tmux bottom,40% --layout reverse --border top'

        zoxide init fish | source


      '';

      preferAbbrs = true;
      shellAbbrs = {
        vnx = "nvim ~/.dotfiles/nixos/";
        vhm = "nvim ~/.dotfiles/nixos/modules/home/";
        v = "nvim";
        qa = "exit";
        # vim = "nvim";


      };
      shellAliases = {

        nvi = "nvim $(fzf --preview 'bat --color=always {}')";
        x-r = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
        h-r = "home-manager switch --flake ~/.dotfiles/nixos/.";

      };

    };
    # fzf.enableFishIntegration = true;
  };
  home.sessionVariables = {
    BROWSER = "zen";
    EDITOR = "nvim";
        CODELLDB_PATH =
        "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };

}
