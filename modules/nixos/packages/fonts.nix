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
            "Iosevka Nerd Font"
            "Noto Naskh Arabic"
          ];
          sansSerif = lib.mkDefault [
            "Noto Naskh Arabic"
            "Noto Sans"
          ];
          serif = lib.mkDefault [
            "Noto Naskh Arabic"
            "Noto Sans"
          ];
        };
        subpixel.rgba = lib.mkDefault "rgb";
      };

      fontDir.enable = true;

      packages = with pkgs; [
        sf-pro # San Francisco Pro
        sf-mono # San Francisco Mono (great for terminals)
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
