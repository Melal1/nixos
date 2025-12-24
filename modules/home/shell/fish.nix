{ pkgs, config, hostname, ... }: {
  programs = {
    fish = {
      enable = true;
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
          {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
          sha256 = "T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";

        };
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

        set fish_greeting # Disable greeting
        # Only run fastfetch in interactive shells, but skip Neovim and tmux
        if status --is-interactive; and not set -q NVIM; and not set -q TMUX
            # fastfetch
        end


        # set -g fish_key_bindings fish_vi_key_bindings
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
      '' + (if config.programs.yazi.enable then ''
        function y
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        end
      '' else "");

      preferAbbrs = true;
      shellAbbrs = {
        vnx = "nvim ~/.dotfiles/nixos/";
        xpkg = "nvim ~/.dotfiles/nixos/modules/packages/";
        vhm = "nvim ~/.dotfiles/nixos/modules/home/";
        qa = "exit";
        x-r = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/.#";
        h-r = (if hostname == "alpha" then
          "home-manager switch --flake ~/.dotfiles/nixos#alpha"
        else if hostname == "zeta" then
          "home-manager switch --flake ~/.dotfiles/nixos#zeta"
        else
          "home-manager switch --flake ~/.dotfiles/nixos/.#"
        );
        cursS = "nix develop ~/.dotfiles/nixos/.#ncurses";
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
    BROWSER = "zen";
    EDITOR = "nvim";
    CODELLDB_PATH =
      "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
  };
}

