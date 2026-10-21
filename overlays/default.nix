_: prev:
(import ../pkgs prev)
// {
  optimizeForArch = import ../lib/optimize-for-arch.nix;

  openblas =
    if prev.stdenv.hostPlatform.system == "i686-linux" then
      prev.openblas.overrideAttrs (_: {
        doCheck = false;
      })
    else
      prev.openblas;

  btop = prev.btop.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./patches/btop-gpureclaim.patch
    ];
  });
}
