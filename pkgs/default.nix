# Custom packages. Exposed everywhere as pkgs.dwm, pkgs.dwmblocks-async and
# pkgs.xwinwrap via overlays/default.nix, and buildable standalone through the
# flake packages output: nix build .#dwm
pkgs: {
  dwm = pkgs.dwm.overrideAttrs (old: {
    src = ./dwm;
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.libX11
      pkgs.libXinerama
      pkgs.libXft
      pkgs.libxcb
      pkgs.fribidi
      pkgs.fontconfig
    ];
  });

  dwmblocks-async = pkgs.callPackage ./dwmblocks-async { };

  xwinwrap = pkgs.callPackage ./xwinwrap { };
}
