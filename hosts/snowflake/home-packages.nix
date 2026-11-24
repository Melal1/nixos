{ inputs
, lib
, pkgs
, unstable
, ...
}:
let
  fromSystem = import ../../modules/home/lib/after-home-packages.nix lib;
  sys = pkgs.stdenv.hostPlatform.system;
  discordPkgs = import inputs.discord-tmp {
    system = sys;
    config.allowUnfree = true;
  };
in
{
  imports = [ inputs.rea-flake.homeManagerModules.default ];
  programs.neovim = {
    enable = lib.mkDefault true;
    withRuby = lib.mkDefault false;
    withPython3 = lib.mkDefault true;
    sideloadInitLua = true; # The user's Neovim checkout owns ~/.config/nvim/init.lua.
    package = inputs.neovim-nightly-overlay.packages.${sys}.default;
  };

  programs.rea = {
    enable = false;
    # REA rejects the Node 24.21.0 runtime in the pinned nixpkgs.
    package = inputs.rea-flake.packages.${sys}.rea.override {
      nodejs_24 = pkgs.nodejs_22;
      # REA requires Ghidra 12.1.x; stable still provides 12.0.4.
      inherit (unstable) ghidra;
    };
  };

  home.packages = fromSystem (
    (with pkgs; [
      # Development and electronics
      # Personal Android client, available independently of the host webcam bundle.
      android-tools
      jetbrains.rider

      # System monitoring
      btop-rocm

      # Communication
      discordPkgs.discord

      # Media and graphics
      imagemagick
      kdePackages.kdenlive
      puddletag
      exiftool

      # password manager
      keepassxc

      # Gaming
      prismlauncher
    ])
    ++ (with unstable; [
      # Development assistants
      codex
      # opencode

      # Networking and remote access
      cloudflared
      anydesk

      # Media
      vlc
      # Keep the former shared CLI priority so Noctalia's stable FFmpeg wins.
      ffmpeg
    ])
    ++ [
      # Terminal communication
      # inputs.tincan-cli.packages.${sys}.default

      # Typing practice
      inputs.toofan.packages.${sys}.default
      inputs.serein.packages.${sys}.default

    ]
  );
}
