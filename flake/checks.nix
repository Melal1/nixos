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
      niriHomes = homeConfigs // {
        rusty-alternate-noctalia = homeConfigs."melal@rusty".extendModules {
          modules = [
            {
              my.home.noctalia = {
                enable = true;
                configFile = toString (
                  pkgs.writeText "rusty-noctalia-fixture.toml" "[appearance]\nfont_size = 18\n"
                );
              };
            }
          ];
        };
        disabled-applications = homeConfigs."melal@snowflake".extendModules {
          modules = [
            {
              programs.kitty.enable = false;
              programs.foot.enable = false;
              my.home.media.enable = false;
              my.home.noctalia.enable = lib.mkForce false;
              my.home.skwd.enable = false;
            }
          ];
        };
      };
    in
    {
      checks = {
        module-evaluation =
          let
            results = import ../tests/module-evaluation.nix { inherit self inputs; };
          in
          pkgs.writeText "module-evaluation-check" (builtins.toJSON results);

        profile-priority = import ../tests/profile-priority.nix {
          inherit pkgs inputs;
          home = homeConfigs."melal@snowflake";
        };

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

        user-scripts =
          pkgs.runCommand "user-scripts-check"
            {
              nativeBuildInputs = [
                pkgs.bash
                pkgs.fish
              ];
            }
            ''
              ${lib.concatMapStringsSep "\n" (
                homeName:
                let
                  cfg = homeConfigs.${homeName}.config;
                in
                ''
                  fish --no-execute ${
                    pkgs.writeText "${homeName}-fish.fish" (
                      builtins.unsafeDiscardStringContext (
                        cfg.programs.fish.shellInit + "\n" + cfg.programs.fish.interactiveShellInit
                      )
                    )
                  }
                  ${lib.concatMapStringsSep "\n"
                    (
                      name:
                      lib.optionalString (cfg.home.file ? ${name}) ''
                        bash -n ${
                          pkgs.writeText "${homeName}-${builtins.baseNameOf name}.sh" (
                            builtins.unsafeDiscardStringContext cfg.home.file.${name}.text
                          )
                        }
                      ''
                    )
                    [
                      ".local/bin/niri-autostart"
                      ".local/bin/mpv-mix"
                    ]
                  }
                ''
              ) (builtins.attrNames homeConfigs)}
              for script in ${../modules/home/scripts}/*.sh ${../modules/home/programs/ncmpcpp/thumbnail.sh}; do
                bash -n "$script"
              done
              touch "$out"
            '';

        niri-config = pkgs.runCommand "niri-config-check" { nativeBuildInputs = [ pkgs.niri ]; } ''
          mkdir -p niri
          cp ${../modules/home/programs/wm/niri/session.kdl} niri/config.kdl
          cp ${../modules/home/programs/wm/niri/themes/default.kdl} niri/default.kdl
          ${lib.concatMapStringsSep "\n" (
            homeName:
            lib.optionalString niriHomes.${homeName}.config.my.home.wm.niri.enable ''
              cp --remove-destination ${
                pkgs.writeText "${homeName}-browser.kdl"
                  niriHomes.${homeName}.config.xdg.configFile."niri/browser.kdl".text
              } niri/browser.kdl
              cp --remove-destination ${
                pkgs.writeText "${homeName}-applications.kdl"
                  niriHomes.${homeName}.config.xdg.configFile."niri/applications.kdl".text
              } niri/applications.kdl
              ${lib.optionalString niriHomes.${homeName}.config.my.home.noctalia.enable ''
                cp ${../modules/home/programs/noctalia/niri.kdl} niri/noctalia.kdl
              ''}
              niri validate --config niri/config.kdl
              rm -f niri/noctalia.kdl
            ''
          ) (builtins.attrNames niriHomes)}
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
