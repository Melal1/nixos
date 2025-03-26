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
          type = "os";
          key = "OS  ";
          keyColor = "31"; # = color1
        }
        {
          type = "kernel";
          format = "{} ";
          key = "KER ";
          keyColor = "32";
        }
        {
          type = "packages";
          key = "PKG ";
          keyColor = "33";
        }
        {
          type = "shell";
          format = "  fish~";
          key = "SH  ";
          keyColor = "34";
        }
        {
          type = "terminal";
          key = "TER ";
          keyColor = "35";
        }
        {
          type = "wm";
          format = "{} ";
          key = "WM  ";
          keyColor = "36";
        }
        "break"
      ];
    };
  };
}
