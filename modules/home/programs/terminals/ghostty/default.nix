{
  programs.ghostty = {
    enable = true;
    settings = {
      # theme = "vague";
      font-size = 16;
      font-family = "CaskaydiaCove Nerd Font";
      font-style = "SemiBold";
      font-style-bold = "Bold";
      font-style-italic = "SemiBold Italic";
      font-style-bold-italic = "Bold Italic";
      font-feature = "ss02";

      window-padding-balance = true;
      window-decoration = false;
      window-theme = "system";
      confirm-close-surface = false;
      resize-overlay = "never";
      quit-after-last-window-closed = false;
      adjust-cell-width = 0;
      adjust-cell-height = "-1%";
      bold-is-bright = true;

      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 2;
      cursor-style = "block";
      window-vsync = false;
      background-opacity = 0.83;
      background-blur = 20;
      background = "#141415";
      foreground = "#cdcdcd";
      selection-background = "#878787";
      selection-foreground = "#cdcdcd";
      cursor-color = "#cdcdcd";
      cursor-text = "#141415";

      palette = [
        "0=#252530" # black
        "1=#d8647e" # red
        "2=#7fa563" # green
        "3=#f3be7c" # yellow
        "4=#6e94b2" # blue
        "5=#bb9dbd" # magenta
        "6=#aeaed1" # cyan
        "7=#cdcdcd" # white
        "8=#606079" # bright black
        "9=#e08398" # bright red
        "10=#99b782" # bright green
        "11=#f5cb96" # bright yellow
        "12=#8ba9c1" # bright blue
        "13=#c9b1ca" # bright magenta
        "14=#bebeda" # bright cyan
        "15=#d7d7d7" # bright white
      ];



      keybind = [
        "clear"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+comma=reload_config"
        "ctrl+shift+a=select_all"
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
      ];
    };

    enableFishIntegration = true;
  };
}

