{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.home.desktop.enable = lib.mkEnableOption "GTK/Qt desktop styling and the pointer theme";

  config = lib.mkIf config.my.home.desktop.enable {
    dconf = {
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          color-scheme = "prefer-dark";
        };
      };
    };
    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
    home.pointerCursor = {
      enable = true;
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 48;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      theme.package = pkgs.gnome-themes-extra;
      gtk4.theme = null;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
