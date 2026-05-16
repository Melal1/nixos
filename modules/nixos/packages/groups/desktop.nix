{ pkgs, unstable, config, lib, ... }: {
  config = lib.mkIf config.my.groups.desktop.enable {
    programs.kdeconnect.enable = true;
    environment.systemPackages = (with pkgs; [
      normcap
      papirus-icon-theme
      apple-cursor
      bibata-cursors
      sioyek
      xournalpp
      unoconv
      firefox
      kdePackages.dolphin
      kdePackages.okular
      kitty
      btop-rocm
      imagemagick
    ]) ++ (with unstable; [
      localsend
      vicinae
      staruml
      brave
    ]);
  };
}
