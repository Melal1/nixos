{ pkgs, inputs, lib, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Spotify is proprietary; allow it via predicate to avoid a blanket allowUnfree
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "spotify" ];

  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.text;

    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      history
      keyboardShortcut
      volumePercentage
    ];
  };
}
