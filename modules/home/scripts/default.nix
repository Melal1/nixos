{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
let
  cfg = config.my.home.scripts;
  # Explicit runtime PATHs retain existing scripts' shell behavior.
  script = name: inputs: text: {
    source = "${pkgs.writeShellScriptBin name ''
      export PATH=${lib.makeBinPath inputs}:$PATH
      ${text}
    ''}/bin/${name}";
    executable = true;
  };
  fileScript =
    name: inputs: file:
    script name inputs (builtins.readFile file);
in
{
  imports = [ ./play-rec.nix ];
  options.my.home.scripts = {
    enable = lib.mkEnableOption "personal shell and desktop helpers";
    githubUsername = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching "[A-Za-z0-9-]+");
      default = null;
      description = "GitHub account for the repository menu.";
    };
    vicinae.enable = lib.mkEnableOption "Vicinae menus and their runtime dependency";
    assets = {
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Assets repository URL.";
      };
      httpsUrl = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "HTTPS fallback for the assets repository.";
      };
      quickshellUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "External Quickshell configuration repository.";
      };
      neovimUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "External Neovim configuration repository.";
      };
      neovimBranch = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "External Neovim configuration branch.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.file = lib.mkMerge [
      {
        ".local/bin/assets-setup" = {
          source = "${
            import ./assets-setup.nix {
              inherit pkgs;
              inherit (cfg) assets;
              dotfilesDir = config.my.home.dotfilesDir;
            }
          }/bin/assets-setup";
          executable = true;
        };
        ".local/bin/theme-switch" = {
          source = "${import ./theme-switch.nix { inherit pkgs; }}/bin/theme-switch";
          executable = true;
        };
        ".local/bin/vmrss" = fileScript "vmrss" (with pkgs; [
          coreutils
          gnugrep
          gawk
          bc
          procps
        ]) ./vmrss.sh;
        ".local/bin/gengitcommit" = fileScript "gengitcommit" (with pkgs; [
          git
          coreutils
          wl-clipboard
          xclip
        ]) ./gitcommit.sh;
        ".local/bin/open-github-tmux" = fileScript "open-github-tmux" (with pkgs; [
          git
          tmux
          fzf
          xdg-utils
        ]) ./open-github-tmux.sh;
      }
      (lib.mkIf config.my.home.desktop.enable {
        ".local/bin/bright" = fileScript "bright" (with pkgs; [
          brightnessctl
          libnotify
          coreutils
        ]) ./brightness.sh;
      })
      (lib.mkIf (cfg.vicinae.enable && cfg.githubUsername != null) {
        ".local/bin/vicinaegithub.sh" =
          script "vicinaegithub.sh"
            (with pkgs; [
              curl
              jq
              coreutils
              xdg-utils
              unstable.vicinae
            ])
            (
              lib.replaceStrings [ "@githubUsername@" ] [ cfg.githubUsername ] (
                builtins.readFile ./vicinae-github.sh
              )
            );
      })
    ];
  };
}
