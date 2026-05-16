{ pkgs, unstable, config, lib, ... }: {
  config = lib.mkIf config.my.groups.core.enable {
    programs.adb.enable = true;
    environment.systemPackages = (with pkgs; [
      jmtpfs alsa-utils pavucontrol libnotify xdg-user-dirs jq
      delta lolcat figlet timer browsh mpc playerctl tmux unzip ripgrep
      fd tree zoxide bat eza fastfetch fish fzf grc starship moreutils
      yarn lsof lsd home-manager vdhcoapp tealdeer smassh asciiquarium
      (ncmpcpp.override { visualizerSupport = true; clockSupport = true; })
      lazygit yazi
    ]) ++ (with unstable; [
      timr-tui dooit neovim tree-sitter
    ]);
  };
}
