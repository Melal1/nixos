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
  # - inotify: bump watch/instance caps so heavy LSP clients (Roslyn LSP,
  # dotnet-easydotnet, watches on large workspaces) don't hit ENOSPC on
  # inotify_add_watch. 1048576 = 2x the previous ceiling; safe, ~1GB kernel
  # mem worst-case (1KB/watch), typically far less.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_queued_events" = 16384;
  };
  # - Base installtion pkgs
  environment = {
    systemPackages = with pkgs; [
      wget
      curl
      git
    ];
  };
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

}
