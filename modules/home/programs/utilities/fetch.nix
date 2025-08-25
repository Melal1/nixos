{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "small";
        # source = "~/.config/settings/ascii/rose.txt"; # Uncomment if you want to use a custom logo
        padding = {
          top = 1;
          right = 6;
        };
      };

      display = {
        separator = " ›  ";
      };

      modules = [
        "break"
        
        {
          type = "Title";
          format = "{}";
          key = "USR ";
          keyColor = "36";
        }
        {
          type = "os";
          key = "OS  ";
          keyColor = "31"; # = color1
          format = "{2}";
        }
        {
          type = "CPU";
          format = "{} ";
          key = "CPU ";
          keyColor = "32";
        }
        {
          type = "GPU";
          key = "GPU ";
          format = "{2} ";
          keyColor = "33";
        }
        {
          type = "shell";
          format = "{}";
          key = "SH  ";
          keyColor = "34";
        }
        {
          type = "terminal";
          key = "TER ";
          format = "{1}";
          keyColor = "35";
        }
        "break"
        "break"
      ];
    };
  };
}
