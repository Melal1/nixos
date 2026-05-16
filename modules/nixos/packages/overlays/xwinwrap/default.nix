{ lib
, stdenv
, xorg
}:

stdenv.mkDerivation {
  pname = "xwinwrap";
  version = "local";

  src = lib.cleanSource ./.;

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXrender
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    install -Dm755 ./xwinwrap $out/bin/xwinwrap
  '';

  meta = with lib; {
    platforms = platforms.linux;
    mainProgram = "xwinwrap";
  };
}
