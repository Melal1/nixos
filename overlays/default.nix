final: prev: {
  openblas =
    if prev.stdenv.hostPlatform.system == "i686-linux"
    then prev.openblas.overrideAttrs (_: {doCheck = false;})
    else prev.openblas;
}
