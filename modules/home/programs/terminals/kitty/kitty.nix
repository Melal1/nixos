{ hostname, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "CaskaydiaCove NF SemiBold";
      size = 15;
    };
    settings = {
      bold_font = "CaskaydiaCove NF Bold";
      italic_font = "auto";
      bold_italic_font = "CaskaydiaCove NF Bold Italic";
      modify_font_cell_width = "96%";
      modify_font_underline_position = "-2";
      modify_font_underline_thickness = "150%";
      modify_font_strikethrough_position = "2px";
      # allow_remote_control = "yes";
      linux_disable_bracketed_paste = "yes"; # Fixes paste delay



      input_delay = "0"; # Reduces input buffering
      sync_to_monitor = "no"; # Prevents vsync-induced input lag

      disable_ligatures = "cursor";
      undercurl_style = "thin-dense";
      scrollback_indicator_opacity = "0.5";
      mouse_hide_wait = "-1.0";
      url_color = "#FFFFFF";
      url_style = "curly";
      show_hyperlink_targets = "yes";
      active_border_color = "none";
      background_opacity = "0.9";

      shell_integration = "no-cursor";
      cursor_shape = "block";
      cursor_beam_thickness = "2";
      cursor_shape_unfocused = "underline";
      cursor_blink_interval = "0.6";
      cursor_stop_blinking_after = "40.0";
      cursor_trail = "10";
      cursor_trail_start_threshold = "0";
      cursor_trail_decay = "0.01 0.15";
      cursor_blink = "true";
      window_padding_width = "1";

      wheel_scroll_multiplier = "10.0";
      open_url_with = "$BROWSER";
      copy_on_select = "no";
      paste_actions = "no-op";
      strip_trailing_spaces = "smart";
      # input_delay = "1";
      # sync_to_monitor = "yes";
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty";
      enable_audio_bell = "yes";
    };
    keybindings = {
      "ctrl+shift+q" = "no_op";
      "ctrl+shift+g" = "no_op";
      "ctrl+shift+3" = "mouse_select_command_output";
      "ctrl+shift+1" = "clear_selection";
      "f5" = "load_config_file";
      "ctrl+shift+2" = "show_last_visited_command_output";
      "ctrl+shift+k" = "scroll_page_up";
      "ctrl+shift+j" = "scroll_page_down";
      "ctrl+j" = "scroll_line_down";
      "ctrl+k" = "scroll_line_up";
      "ctrl+shift+c" = "copy_and_clear_or_interrupt";
    };
    extraConfig = ''
      # Include the theme file
      include ~/.config/kitty/current.conf
    '';
  };
}
