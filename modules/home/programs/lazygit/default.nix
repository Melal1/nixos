{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = lib.mkIf config.programs.lazygit.enable [ pkgs.delta ];

  programs.lazygit = {

    settings = {
      git = {
        pagers = lib.mkDefault [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never --syntax-theme base16-256 -s --wrap-max-lines=10";
          }
          # Optional: fall back to git's external diff config
          # { useExternalDiffGitConfig = true; }
        ];
      };
    };
  };
}
