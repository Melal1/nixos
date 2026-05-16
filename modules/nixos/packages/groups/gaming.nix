{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.my.groups.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    environment.systemPackages = with pkgs; [
      prismlauncher
    ];
  };
}
