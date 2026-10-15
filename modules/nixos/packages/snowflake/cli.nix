{ pkgs, unstable, ... }:
{
  environment.systemPackages =
    (with pkgs; [
      # Shared non-Java shell packages are installed through development.nix.
      btop-rocm
      imagemagick
      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      prettier
      eslint
    ])
    ++ (with unstable; [
      # (timr-tui.override { enableSound = true; })
      codex
    ]);
}
