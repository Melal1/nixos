# Exercise buildEnv with the real profile's package priorities, replacing heavy
# application contents with tiny probes. Duplicate outputs retain their identity.
{
  pkgs,
  inputs,
  home,
}:
let
  inherit (pkgs) lib;
  cfg = home.config;
  cases = {
    ffmpeg = {
      names = [ "ffmpeg" ];
      expected = home.pkgs.ffmpeg;
    };
    python = {
      names = [ "python3" ];
      expected = home.pkgs.python3;
    };
    quickshell = {
      names = [
        "quickshell"
        "quickshell-wrapped"
      ];
      expected = inputs.quickshell-niri.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };
  };
  identity =
    package: builtins.hashString "sha256" (builtins.unsafeDiscardStringContext package.outPath);
  probe =
    command: package:
    pkgs.runCommand "${command}-priority-probe"
      {
        meta.priority = package.meta.priority or lib.meta.defaultPriority;
      }
      ''
        mkdir -p "$out/bin"
        printf '%s\n' ${lib.escapeShellArg (identity package)} > "$out/bin/${command}"
      '';
  checkCase =
    command: case:
    let
      selected = builtins.filter (p: builtins.elem (lib.getName p) case.names) cfg.home.packages;
      profile = pkgs.buildEnv {
        name = "${command}-priority-profile";
        paths = map (probe command) selected;
        pathsToLink = [ "/bin" ];
      };
    in
    assert lib.assertMsg (
      builtins.length (lib.unique (map identity selected)) >= 2
    ) "The ${command} priority fixture must exercise multiple variants.";
    ''
      test "$(cat ${profile}/bin/${command})" = ${lib.escapeShellArg (identity case.expected)}
    '';
in
pkgs.runCommand "profile-priority-check" { } (
  lib.concatStringsSep "\n" (lib.mapAttrsToList checkCase cases) + "\ntouch \"$out\"\n"
)
