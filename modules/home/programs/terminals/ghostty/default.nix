{ config, ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # theme = "vague";
      font-size = 18;
      font-family = "CaskaydiaCove Nerd Font";
      font-style = "SemiBold";
      # font-style-bold = "Bold";
      # font-style-italic = "SemiBold Italic";
      # font-style-bold-italic = "Bold Italic";

      window-padding-balance = true;
      window-decoration = false;
      window-theme = "system";
      confirm-close-surface = false;
      resize-overlay = "never";
      quit-after-last-window-closed = true;
      quit-after-last-window-closed-delay = "10m";
      gtk-single-instance = "detect";
      adjust-cell-width = 0;
      adjust-cell-height = "+10%";
      bold-color = "bright";
      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 2;
      cursor-style = "block";
      window-vsync = false;
      config-file = "${config.home.homeDirectory}/.config/ghostty/theme";

      keybind = [
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+comma=reload_config"
        "ctrl+shift+a=select_all"
        "ctrl+equal=increase_font_size:1"
        "ctrl+plus=increase_font_size:1"
        "ctrl+shift+equal=increase_font_size:1"
        "ctrl+shift+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };

    enableFishIntegration = true;
  };
}

