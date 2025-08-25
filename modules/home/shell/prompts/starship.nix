{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format =
        "$os"
        + "$username"
        + "$hostname"
        + "$directory"
        + "$git_branch"
        + "$git_commit"
        + "$git_state"
        + "$nix_shell"
        + "$docker_context"
        + "$fill"
        + "$git_metrics"
        + "$git_status"
        + "$line_break"
        + "$jobs"
        + "$container"
        + "$character";

      right_format = ""; # Disable the right_format since we're using fill

      add_newline = false;
      fill = {
        symbol = " ";
      };
      os = {
        format = "[$symbol]($style) ";
        disabled = true;
        symbols = {
          NixOS = "󱄅 ";
        };
      };

      nix_shell = {
        format = "[󱄅 $name]($style) ";
      };

      directory = {
        format = " ($style)[$path]($style) [$read_only]($read_only_style)";
      };

      git_branch = {
        format = "[$symbol($branch)]($style) ";
        symbol = "  ";
      };

      git_status = {
        renamed = "󰑎 ";
      };

      git_metrics = {
        added_style = "bright-green bold";
        deleted_style = "bright-red bold";
        format = "([󰞱$added ]($added_style) )([-$deleted]($deleted_style) )";
        disabled = false;
      };
    };
  };
}
