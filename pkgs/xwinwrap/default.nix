{ lib
, stdenv
, libX11
, libXext
, libXrender
}:

stdenv.mkDerivation {
  pname = "xwinwrap";
  version = "local";

  src = lib.cleanSource ./.;

  buildInputs = [
    libX11
    libXext
    libXrender
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
