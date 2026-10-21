{ pkgs }:
let
  inherit (pkgs) lib;
  shells = import ./default.nix { inherit pkgs; };

  packagesFor =
    names:
    map
      (
        package:
        # Prefer the scientific Python environment's commands. Keep the plain
        # interpreter available without pulling optional documentation builds.
        if package.outPath == pkgs.python313.outPath then
          builtins.removeAttrs (lib.lowPrio package) [ "doc" ]
        # Keep the desktop's QML-enabled Quickshell preferred over the shell build.
        else if package.outPath == pkgs.quickshell.outPath then
          lib.lowPrio package
        else
          package
      )
      (
        lib.unique (
          lib.concatMap (
            name:
            let
              shell = shells.${name};
            in
            lib.concatMap
              (
                package:
                # mkShell selects dev outputs for many libraries. Keep those
                # headers as well as the package's usual installed outputs.
                [ package ]
                ++ lib.optional ((package.outputName or "") == "dev") (
                  (package.out or package) // { outputSpecified = false; }
                )
              )
              (
                (shell.nativeBuildInputs or [ ])
                ++ (shell.buildInputs or [ ])
                ++ (shell.propagatedNativeBuildInputs or [ ])
                ++ (shell.propagatedBuildInputs or [ ])
                ++ (shell.runtimePackages or [ ])
              )
          ) names
        )
      );
in
{
  # Reuse exactly the same packages and output handling for individual selections.
  inherit packagesFor;
  names = builtins.attrNames shells;

  nonJava = packagesFor (lib.remove "javafx" (builtins.attrNames shells));
  cpp = packagesFor [
    "cpp"
    "audio"
    "dpp"
    "fmt"
    "ncurses"
    "qksh"
  ];
}
