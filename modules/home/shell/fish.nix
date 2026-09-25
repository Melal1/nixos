{
  pkgs,
  config,
  lib,
  hostname,
  ...
}:
{
  programs = {
    fish = {
      enable = true;
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

      shellInit = ''
        function fish_title
            set -q argv[1]; or set argv fish

            if test "$argv[1]" = "fish"
                echo (prompt_pwd --dir-length=0)
            else
                echo "$argv[1]"
            end
        end

        function fzf --wraps=fzf --description="Use fzf-tmux if in tmux session"
          if set --query TMUX
            fzf-tmux $argv
          else
            command fzf $argv
          end
        end

        function rgn
          set -l res (rg --color=always --line-number --no-heading --smart-case $argv | fzf --ansi --delimiter : --preview 'bat --color=always {1} --highlight-line {2}' --preview-window 'up,60%,+{2}-10')
          if test -n "$res"
            set -l tokens (string split ":" $res)
            # tokens[1] is the file path, tokens[2] is the line number
            nvim +$tokens[2] $tokens[1]
          end
        end

        function rgi
          set -l res (fzf --disabled --ansi \
            --bind "start:reload(rg --column --line-number --no-heading --color=always --smart-case ''')" \
            --bind "change:reload(rg --column --line-number --no-heading --color=always --smart-case {q} || true)" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,+{2}-10')
            
          if test -n "$res"
            set -l tokens (string split ":" $res)
            nvim +$tokens[2] $tokens[1]
          end
        end

        set fish_greeting # Disable greeting
        # Only run fastfetch in interactive shells, but skip Neovim and tmux
        if status --is-interactive; and not set -q NVIM; and not set -q TMUX
            # fastfetch
        end


        set -g fish_key_bindings fish_vi_key_bindings
        # bind -M visual y fish_clipboard_copy
        # bind -M normal yy fish_clipboard_copy
        # bind p fish_clipboard_paste
        bind \cE edit_command_buffer
        bind \cQ up-or-search
        bind \cA down-or-search
        bind -M insert \cQ up-or-search
        bind -M insert \cA down-or-search
        bind -M insert \cB edit_command_buffer
        bind -M insert \cD nextd-or-forward-word
        bind -M insert \cE accept-autosuggestion
        bind -M insert -m default jk cancel repaint-mode
        set -g fish_sequence_key_delay_ms 60
        # bind --erase \cr
        # bind --erase \ct
        # bind --erase \ef
        # bind --erase \ec
        # bind --erase -M insert \cr
        # bind --erase -M insert \ct
        # bind --erase -M insert \ec
        # bind \cx fzf-history-widget
        # bind \cs nvi
        # bind \ec fzf-cd-widget
        # bind -M insert \cx fzf-history-widget
        # bind -M insert \cs nvi
        # bind -M insert \ec fzf-cd-widget

        set -x FZF_ALT_C_OPTS "--preview 'test -d {} && lsd --tree --depth=1 --icon=always --color=always {} || echo {} is not a directory'"
        set -x FZF_DEFAULT_OPTS '--height 70% --tmux bottom,40% --layout reverse --border top'

        zoxide init fish | source
        if status --is-interactive
        eval (direnv hook fish)
        end





      ''
      + lib.optionalString config.programs.yazi.enable ''
        function y
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        end
      '';

      preferAbbrs = true;
      shellAbbrs = {
        vnx = "nvim ~/.dotfiles/nixos/";
        xpkg = "nvim ~/.dotfiles/nixos/modules/packages/";
        vhm = "nvim ~/.dotfiles/nixos/modules/home/";
        qa = "exit";
        x-r = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
        h-r = "home-manager switch --flake ~/.dotfiles/nixos/#${toString hostname}";
      };

      shellAliases = {
        nvi = "nvim $(fzf --preview 'bat --color=always {}')";
        v = "nvim";
        vim = "nvim";
        vi = "nvim";
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "brave-origin";
    EDITOR = "nvim";
    CODELLDB_PATH = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };
}
