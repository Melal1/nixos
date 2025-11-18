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
      # WARN: this will install all the fonts , for override it will fetch all .
      # TODO: make a repo contain all the fonts i use then install them via nix .
      noto-fonts
      noto-fonts-emoji
      twitter-color-emoji
      sarasa-gothic
      noto-fonts-cjk-sans
      nerd-fonts.iosevka
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      (google-fonts.override { fonts = [ "Radio Canada Big" ]; })
    ];

  };

}
