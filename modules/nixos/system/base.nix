{ pkgs, ... }:
{
  time.timeZone = "Asia/Riyadh";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ar_SA.UTF-8/UTF-8"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";

  environment = {
    systemPackages = with pkgs; [
      wget
      curl
      lsof
    ];
  };
}
