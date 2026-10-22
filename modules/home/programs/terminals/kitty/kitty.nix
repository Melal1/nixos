{
  config,
  lib,
  unstable,
  ...
}:
lib.mkIf config.programs.kitty.enable {
  programs.kitty = {
    package = lib.mkDefault unstable.kitty;
    font = {
      name = lib.mkDefault "CaskaydiaCove Nerd Font";
      size = lib.mkDefault 18;
    };
    settings = {
      bold_font = lib.mkDefault "auto";
      italic_font = lib.mkDefault "auto";
      bold_italic_font = lib.mkDefault "auto";
      # allow_remote_control = "yes";

      input_delay = lib.mkDefault "0"; # Reduces input buffering
      sync_to_monitor = lib.mkDefault "no"; # Prevents vsync-induced input lag

      disable_ligatures = lib.mkDefault "cursor";
      undercurl_style = lib.mkDefault "thin-dense";
      mouse_hide_wait = lib.mkDefault "-1.0";
      url_color = lib.mkDefault "#FFFFFF";
      url_style = lib.mkDefault "curly";
      show_hyperlink_targets = lib.mkDefault "yes";
      active_border_color = lib.mkDefault "none";

      shell_integration = lib.mkDefault "no-cursor";
      cursor_shape = lib.mkDefault "block";
      cursor_beam_thickness = lib.mkDefault "2";
      cursor_shape_unfocused = lib.mkDefault "underline";
      cursor_blink_interval = lib.mkDefault "0.6";
      cursor_stop_blinking_after = lib.mkDefault "40.0";
      cursor_trail = lib.mkDefault "10";
      cursor_trail_start_threshold = lib.mkDefault "0";
      cursor_trail_decay = lib.mkDefault "0.01 0.15";
      window_padding_width = lib.mkDefault "1";

      wheel_scroll_multiplier = lib.mkDefault "10.0";
      open_url_with = "$BROWSER";
      copy_on_select = lib.mkDefault "no";
      paste_actions = lib.mkDefault "no-op";
      strip_trailing_spaces = lib.mkDefault "smart";
      # input_delay = "1";
      # sync_to_monitor = "yes";
      allow_remote_control = "socket-only";
      listen_on = "unix:$XDG_RUNTIME_DIR/kitty";
      enable_audio_bell = lib.mkDefault "yes";
    };
    keybindings = {
      "ctrl+shift+q" = lib.mkDefault "no_op";
      "ctrl+shift+g" = lib.mkDefault "no_op";
      "ctrl+shift+3" = lib.mkDefault "mouse_select_command_output";
      "ctrl+shift+1" = lib.mkDefault "clear_selection";
      "f5" = lib.mkDefault "load_config_file";
      "ctrl+shift+2" = lib.mkDefault "show_last_visited_command_output";
      "ctrl+shift+k" = lib.mkDefault "scroll_page_up";
      "ctrl+shift+j" = lib.mkDefault "scroll_page_down";
      "ctrl+j" = lib.mkDefault "scroll_line_down";
      # "ctrl+k" = "scroll_line_up";
      "ctrl+shift+c" = lib.mkDefault "copy_and_clear_or_interrupt";
    };
    extraConfig = ''
      # Include the theme file
      include ~/.config/kitty/current.conf
    '';
  };
}
