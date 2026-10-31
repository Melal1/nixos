# Bootstrap repositories supplied by the user; never embeds a reusable personal default.
{
  pkgs,
  dotfilesDir,
  assets ? {
    url = null;
    httpsUrl = "";
    quickshellUrl = null;
    neovimUrl = null;
    neovimBranch = "";
  },
}:

pkgs.writeShellApplication {
  name = "assets-setup";
  runtimeInputs = with pkgs; [
    coreutils
    git
    systemd
  ];
  text =
    pkgs.lib.replaceStrings
      [ "@dotfilesDir@" "@assetsRepository@" "@quickshellRepository@" "@neovimRepository@" ]
      [
        (pkgs.lib.escapeShellArg dotfilesDir)
        (pkgs.lib.optionalString (assets.url != null) ''
          sync_repo ${pkgs.lib.escapeShellArg assets.url} "$ASSETS_DIR" "" ${pkgs.lib.escapeShellArg assets.httpsUrl}
        '')
        (pkgs.lib.optionalString (assets.quickshellUrl != null) ''
          sync_repo ${pkgs.lib.escapeShellArg assets.quickshellUrl} "$HOME/.config/quickshell"
        '')
        (pkgs.lib.optionalString (assets.neovimUrl != null) ''
          sync_repo ${pkgs.lib.escapeShellArg assets.neovimUrl} "$HOME/.config/nvim" ${pkgs.lib.escapeShellArg assets.neovimBranch}
        '')
      ]
      (builtins.readFile ./assets-setup.sh);
}
