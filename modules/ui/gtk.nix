{ pkgs, ... }: {

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

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

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
}
