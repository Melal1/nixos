{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.packages.cli.shared.enable {
    environment.systemPackages =
      (with pkgs; [

        ### ──────────────────────
        ###  CLI Utilities
        ### ──────────────────────
        jq
        nmap
        arp-scan
        lolcat
        figlet
        tmux
        unzip
        ripgrep
        fd
        tree
        zoxide
        bat
        eza
        fzf
        grc
        moreutils
        lsof
        lsd
        home-manager
        tealdeer
        bc
      ])
      ++ (with unstable; [
        neovim
        herdr
        zip
        yt-dlp
        rar
        ffmpeg
        opencode
      ])
      ++ lib.optionals config.my.virtualisation.databaseEnabled [
        unstable.lazysql
      ];
  };
}
