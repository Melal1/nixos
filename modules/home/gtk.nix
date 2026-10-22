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
          gtk-theme = lib.mkDefault "Adwaita-dark";
          color-scheme = lib.mkDefault "prefer-dark";
        };
      };
    };
    qt = {
      enable = lib.mkDefault true;
      platformTheme.name = lib.mkDefault "gtk";
    };
    home.pointerCursor = {
      enable = lib.mkDefault true;
      name = lib.mkDefault "macOS";
      package = lib.mkDefault pkgs.apple-cursor;
      size = lib.mkDefault 48;
      gtk.enable = lib.mkDefault true;
      x11.enable = lib.mkDefault true;
    };

    gtk = {
      enable = lib.mkDefault true;
      theme.name = lib.mkDefault "Adwaita-dark";
      theme.package = lib.mkDefault pkgs.gnome-themes-extra;
      gtk4.theme = lib.mkDefault null;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkDefault 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkDefault 1;
      };
    };
  };
}
