{ pkgs, ... }:
{
# - Time 
  time.timeZone = "Asia/Riyadh";
# - Locale
  i18n = {
  defaultLocale = "en_US.UTF-8";
  supportedLocales = [
  "en_US.UTF-8/UTF-8"
  # "ar_SA.UTF-8/UTF-8"
  ];
};
# - Nixos
   nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixpkgs.config.allowUnfree = true;
      system.stateVersion = "24.11"; 
# - Base installtion pkgs
  environment = {
    systemPackages = with pkgs; [
      neovim
      wget
      curl
      git
    ];
    };
  
}
