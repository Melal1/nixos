_: {
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;

    shfmt = {
      enable = true;
      indent_size = 4;
      includes = [
        "modules/home/scripts/*.sh"
        "modules/home/programs/ncmpcpp/thumbnail.sh"
        "tests/*.sh"
      ];
    };

    kdlfmt = {
      enable = true;
      includes = [ "modules/home/programs/wm/niri/session.kdl" ];
    };
  };

  settings.formatter.kdlfmt.options = [
    "--kdl-version"
    "v1"
  ];
}
