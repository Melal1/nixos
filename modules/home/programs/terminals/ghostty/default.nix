{
  programs.ghostty = {
    enable = false;
    settings = {
      # theme = "vague";
      font-size = 20;
      font-family = "FiraCode Nerd Font";
      font-style = "SemiBold";
      # font-style-bold = "Bold";
      # font-style-italic = "SemiBold Italic";
      # font-style-bold-italic = "Bold Italic";

      window-padding-balance = true;
      window-decoration = false;
      window-theme = "system";
      confirm-close-surface = false;
      resize-overlay = "never";
      quit-after-last-window-closed = false;
      adjust-cell-width = 0;
      adjust-cell-height = "+10%";
      bold-is-bright = true;

      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 2;
      cursor-style = "block";
      window-vsync = false;
      theme = "/home/melal/.config/ghostty/theme";

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

