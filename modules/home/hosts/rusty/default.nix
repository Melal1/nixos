{
  imports = [
    ../../packages/cli.nix
    ../../packages/gui.nix
    ../../packages/io.nix
    ../../packages/database-clients.nix
    ../../packages/development.nix
    ../../packages/rusty/cli.nix
    ../../packages/rusty/gui.nix
  ];
  my.home.development.toolchains = {
    cpp.enable = true;
    audio.enable = true;
    dpp.enable = true;
    fmt.enable = true;
    ncurses.enable = true;
    qksh.enable = true;
  };

}
