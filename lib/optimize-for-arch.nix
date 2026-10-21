# Reusable for source packages whose C/C++ builds use NIX_CFLAGS_COMPILE.
# Only this package bypasses binary caches; its dependencies are unchanged.
# Future me do not use on your laptop
{
  package,
  arch,
  optimize_for_arch ? true,
}:
if optimize_for_arch then
  assert builtins.isString arch && builtins.match "[A-Za-z0-9_+-]+" arch != null;
  package.overrideAttrs (
    old:
    let
      usesEnv = old ? env.NIX_CFLAGS_COMPILE;
      oldFlags = if usesEnv then old.env.NIX_CFLAGS_COMPILE else old.NIX_CFLAGS_COMPILE or "";
      flags = "${toString oldFlags} -march=${arch} -O3";
    in
    {
      allowSubstitutes = false;
      preferLocalBuild = true;
    }
    // (
      if usesEnv then
        {
          env = old.env // {
            NIX_CFLAGS_COMPILE = flags;
          };
        }
      else
        { NIX_CFLAGS_COMPILE = flags; }
    )
  )
else
  package
