{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.fonts.shared.enable {
    nixpkgs.overlays = [ inputs.apple-fonts.overlays.default ];

    fonts = {
      fontconfig = {
        enable = lib.mkDefault true;
        defaultFonts = {
          emoji = lib.mkDefault [ "Twitter Color Emoji" ];
          monospace = lib.mkDefault [
            "SF Mono"
            "Iosevka Nerd Font"
            "Noto Naskh Arabic"
          ];
          sansSerif = lib.mkDefault [
            "SF Pro Text"
            "SF Arabic"
            "Noto Sans"
          ];
          serif = lib.mkDefault [
            "New York"
            "SF Arabic"
            "Noto Naskh Arabic"
          ];
        };
        subpixel.rgba = lib.mkDefault "rgb";
      };

      fontDir.enable = true;

      packages = with pkgs; [
        sf-pro # San Francisco Pro
        sf-arabic # SF Arabic font package
        sf-mono # San Francisco Mono
        sf-compact # San Francisco Compact
        ny # New York (Serif)
        noto-fonts
        noto-fonts-color-emoji
        twitter-color-emoji
        atkinson-hyperlegible
        iosevka
        sarasa-gothic
        noto-fonts-cjk-sans
        nerd-fonts.iosevka
        nerd-fonts.caskaydia-cove
        nerd-fonts.jetbrains-mono
        nerd-fonts.agave
        nerd-fonts.fira-code
        (google-fonts.override { fonts = [ "Radio Canada Big" ]; })
      ];
    };
  };
}
