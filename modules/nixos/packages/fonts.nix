{ pkgs, ... }:
{
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Twitter Color Emoji" ];
        monospace = [
          "Iosevka Nerd Font"
          "Noto Naskh Arabic"
        ];
        sansSerif = [
          "Noto Naskh Arabic"
          "Noto Sans"
        ];
        serif = [
          "Noto Naskh Arabic"
          "Noto Sans"
        ];

      };
      subpixel.rgba = "rgb";
    };

    fontDir.enable = true;

    packages = with pkgs; [
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

}
