{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.programs.ncmpcpp.enable {

  home.file.".config/ncmpcpp/thumbnail" = {
    source = "${pkgs.writeShellScriptBin "mpd-thumbnail" ''
      export PATH=${
        lib.makeBinPath [
          pkgs.mpc
          pkgs.libnotify
          pkgs.coreutils
          pkgs.gnused
        ]
      }:$PATH
      export MPD_HOST=${lib.escapeShellArg config.services.mpd.network.listenAddress}
      ${builtins.readFile ./thumbnail.sh}
    ''}/bin/mpd-thumbnail";
    executable = true;
  };

  programs.ncmpcpp = {

    package = lib.mkDefault (
      pkgs.ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      }
    );
    settings = {
      mpd_host = config.services.mpd.network.listenAddress;
      mpd_connection_timeout = lib.mkDefault "5";
      mpd_crossfade_time = lib.mkDefault "5";
      lyrics_directory = lib.mkDefault "~/.config/ncmpcpp/lyrics";
      execute_on_song_change = "~/.config/ncmpcpp/thumbnail";
      visualizer_data_source = "${config.services.mpd.dataDir}/visualizer.fifo";
      visualizer_output_name = "my_fifo";

      visualizer_in_stereo = lib.mkDefault "yes";
      visualizer_fps = lib.mkDefault "60";
      visualizer_type = lib.mkDefault "ellipse";
      visualizer_look = lib.mkDefault "●●";
      visualizer_color = lib.mkDefault "magenta,cyan,blue,red,white,green,yellow,black,magenta";
      visualizer_spectrum_smooth_look = lib.mkDefault "yes";

      # GENERAL
      connected_message_on_startup = lib.mkDefault "yes";
      cyclic_scrolling = lib.mkDefault "yes";
      mouse_support = lib.mkDefault "yes";
      mouse_list_scroll_whole_page = lib.mkDefault "yes";
      lines_scrolled = lib.mkDefault "1";
      message_delay_time = lib.mkDefault "1";
      playlist_shorten_total_times = lib.mkDefault "yes";
      playlist_display_mode = lib.mkDefault "columns";
      browser_display_mode = lib.mkDefault "columns";
      search_engine_display_mode = lib.mkDefault "columns";
      playlist_editor_display_mode = lib.mkDefault "columns";
      autocenter_mode = lib.mkDefault "yes";
      centered_cursor = lib.mkDefault "yes";
      user_interface = lib.mkDefault "classic";
      follow_now_playing_lyrics = lib.mkDefault "yes";
      locked_screen_width_part = lib.mkDefault "50";
      ask_for_locked_screen_width_part = lib.mkDefault "yes";
      display_bitrate = lib.mkDefault "no";
      external_editor = lib.mkDefault "nvim";
      main_window_color = lib.mkDefault "default";
      startup_screen = lib.mkDefault "visualizer";

      # PROGRESS BAR
      progressbar_look = lib.mkDefault "▪▪▪";
      # progressbar_look = "▃▃▃";
      progressbar_elapsed_color = lib.mkDefault "magenta";
      progressbar_color = lib.mkDefault "black";

      # UI VISIBILITY
      header_visibility = lib.mkDefault "no";
      statusbar_visibility = lib.mkDefault "yes";
      titles_visibility = lib.mkDefault "yes";
      enable_window_title = lib.mkDefault "yes";

      # COLORS
      statusbar_color = lib.mkDefault "white";
      color1 = lib.mkDefault "white";
      color2 = lib.mkDefault "blue";

      # UI APPEARANCE
      now_playing_prefix = lib.mkDefault "$b$2$7 ";
      now_playing_suffix = lib.mkDefault "  $/b$8";
      current_item_prefix = lib.mkDefault "$b$7$/b$3 ";
      current_item_suffix = lib.mkDefault "  $8";

      song_columns_list_format = lib.mkDefault "(50)[]{t|fr:Title} (0)[magenta]{a}";
      song_list_format = lib.mkDefault " {%t $R   $8%a$8}|{%f $R   $8%l$8} $8";
      song_status_format = lib.mkDefault "$b$2󰣐 $7 {$b$6$8 %t $6} $7 $8";
      song_window_title_format = lib.mkDefault "Now Playing ..";
    };
    bindings = lib.mkDefault [
      # Basic navigation
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "h";
        command = "previous_column";
      }
      {
        key = "l";
        command = "next_column";
      }

      # Jump 10 lines
      {
        key = "J";
        command = [
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
          "scroll_down"
        ];
      }
      {
        key = "K";
        command = [
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
          "scroll_up"
        ];
      }

      # Play/pause and next/previous
      {
        key = "p";
        command = "pause";
      }
      {
        key = "n";
        command = "next";
      }
      {
        key = "b";
        command = "previous";
      }

      # Volume controls
      {
        key = "+";
        command = "volume_up";
      }
      {
        key = "-";
        command = "volume_down";
      }

      # Toggle visualizer
      {
        key = "v";
        command = "show_visualizer";
      }

      # Quit
      {
        key = "q";
        command = "quit";
      }
    ];
  };
}
