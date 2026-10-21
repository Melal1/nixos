{
  inputs,
  self,
  homeConfigs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
in
{
  perSystem =
    { config, pkgs, ... }:
    let
      inherit (config) devShells;
    in
    {
      checks = {
        module-evaluation =
          let
            results = import ../tests/module-evaluation.nix { inherit self inputs; };
          in
          pkgs.writeText "module-evaluation-check" (builtins.toJSON results);

        shell-hooks = pkgs.runCommand "shell-hooks-check" { nativeBuildInputs = [ pkgs.bash ]; } (
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: shell:
              let
                # Syntax checking only needs the text, not the packages referenced by the hook.
                hook = pkgs.writeText "${name}-shell-hook.sh" (
                  builtins.unsafeDiscardStringContext (shell.shellHook or "")
                );
              in
              "bash -n ${hook}"
            ) devShells
          )
          + "\ntouch \"$out\"\n"
        );

        niri-config = pkgs.runCommand "niri-config-check" { nativeBuildInputs = [ pkgs.niri ]; } ''
          mkdir -p niri
          cp ${../modules/home/programs/wm/niri/config.kdl} niri/config.kdl
          cp ${../modules/home/programs/wm/niri/themes/default.kdl} niri/default.kdl
          ${lib.concatMapStringsSep "\n" (
            homeName:
            lib.optionalString homeConfigs.${homeName}.config.my.home.wm.niri.enable ''
              cp --remove-destination ${
                pkgs.writeText "${homeName}-browser.kdl"
                  homeConfigs.${homeName}.config.xdg.configFile."niri/browser.kdl".text
              } niri/browser.kdl
              ${lib.optionalString homeConfigs.${homeName}.config.my.home.noctalia.enable ''
                cp ${../modules/home/programs/noctalia/niri.kdl} niri/noctalia.kdl
              ''}
              niri validate --config niri/config.kdl
              rm -f niri/noctalia.kdl
            ''
          ) (builtins.attrNames homeConfigs)}
          touch "$out"
        '';

        theme-switch =
          pkgs.runCommand "theme-switch-check"
            {
              nativeBuildInputs = [
                pkgs.bash
                pkgs.coreutils
                pkgs.findutils
                (import ../modules/home/scripts/theme-switch.nix { inherit pkgs; })
              ];
            }
            ''
              bash ${../tests/theme-switch.sh}
              touch "$out"
            '';

        assets-setup =
          pkgs.runCommand "assets-setup-check"
            {
              nativeBuildInputs = [
                pkgs.bash
                pkgs.git
                pkgs.coreutils
                (import ../modules/home/scripts/assets-setup.nix {
                  inherit pkgs;
                  dotfilesDir = self;
                })
              ];
            }
            ''
              bash ${../tests/assets-setup.sh}
              touch "$out"
            '';

        formatting = config.treefmt.build.check self;

        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              deadnix --fail --no-lambda-pattern-names ${self}
              touch "$out"
            '';

        statix =
          pkgs.runCommand "statix-check"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              statix check --config ${self}/statix.toml ${self}
              touch "$out"
            '';
      }
      // lib.mapAttrs' (name: home: lib.nameValuePair "home-${name}" home.activationPackage) homeConfigs;
    };
}
