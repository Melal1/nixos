{ pkgs, unstable, config, lib, ... }: {
  config = lib.mkIf config.my.groups.social.enable {
    environment.systemPackages = (with pkgs; [
      discord
    ]) ++ (with unstable; [
      vesktop
    ]);
  };
}
