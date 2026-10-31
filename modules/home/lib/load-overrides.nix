lib: dir:
if builtins.pathExists dir then
  map (name: dir + "/${name}") (
    builtins.attrNames (
      lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (builtins.readDir dir)
    )
  )
else
  [ ]
