{ lib
, stdenv
, pkg-config
, libX11
, fribidi
, libxcb
, xcbutil
, blocksH ? null # optional path to a generated blocks.h (host-specific)
}:

stdenv.mkDerivation {
  pname = "dwmblocks-async";
  version = "4.20.24";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libX11 fribidi libxcb xcbutil ];

  preBuild = lib.optionalString (blocksH != null) ''
    cp ${blocksH} blocks.h
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Async dwmblocks";
    license = lib.licenses.bsd3;
  };
}
