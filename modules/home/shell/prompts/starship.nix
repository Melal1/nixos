{ lib, ... }:
{
  programs.starship = {
    enableTransience = lib.mkDefault true;
    settings = {
      format = lib.mkDefault (
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
        + "$character"
      );

      right_format = lib.mkDefault ""; # Disable the right_format since we're using fill

      add_newline = lib.mkDefault false;
      fill = {
        symbol = lib.mkDefault " ";
      };
      os = {
        format = lib.mkDefault "[$symbol]($style) ";
        disabled = lib.mkDefault true;
        symbols = {
          NixOS = lib.mkDefault "󱄅 ";
        };
      };

      nix_shell = {
        format = lib.mkDefault "[󱄅 $name]($style) ";
      };

      directory = {
        format = lib.mkDefault " ($style)[$path]($style) [$read_only]($read_only_style)";
      };

      git_branch = {
        format = lib.mkDefault "[$symbol($branch)]($style) ";
        symbol = lib.mkDefault "  ";
      };

      git_status = {
        renamed = lib.mkDefault "󰑎 ";
      };

      git_metrics = {
        added_style = lib.mkDefault "bright-green bold";
        deleted_style = lib.mkDefault "bright-red bold";
        format = lib.mkDefault "([󰞱$added ]($added_style) )([-$deleted]($deleted_style) )";
        disabled = lib.mkDefault false;
      };
    };
  };
}
